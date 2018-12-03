package Sisimai::Bite::Email::MessageLabs;
use parent 'Sisimai::Bite::Email';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['Content-Type: message/delivery-status'],
    'rfc822'  => ['Content-Type: text/rfc822-headers'],
};
my $ReFailures = {
    'userunknown'   => qr/(?:542 .+ Rejected|No such user)/,
    'securityerror' => qr/Please turn on SMTP Authentication in your mail client/,
};

# X-Msg-Ref: server-11.tower-143.messagelabs.com!1419367175!36473369!1
# X-Originating-IP: [10.245.230.38]
# X-StarScan-Received:
# X-StarScan-Version: 6.12.5; banners=-,-,-
# X-VirusChecked: Checked
sub headerlist  { return ['X-Msg-Ref'] }
sub description { 'Symantec.cloud http://www.messagelabs.com' }
sub scan {
    # Detect an error from MessageLabs.com
    # @param         [Hash] mhead       Message headers of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.1.10
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless defined $mhead->{'x-msg-ref'};
    return undef unless rindex($mhead->{'from'}, 'MAILER-DAEMON@messagelabs.com') > -1;
    return undef unless index($mhead->{'subject'}, 'Mail Delivery Failure') == 0;

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $fieldindex = Sisimai::RFC1894->FIELDINDEX;
    my $mesgfields = Sisimai::RFC1894->FIELDINDEX('mesg');

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my @hasdivided = split("\n", $$mbody);
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $permessage = {};    # (Hash) Store values of each Per-Message field
    my $v = undef;
    my $p = '';
    my $o = [];

    for my $e ( @hasdivided ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            if( index($e, $StartingOf->{'message'}->[0]) == 0 ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part(message/rfc822)
            if( $e eq $StartingOf->{'rfc822'}->[0] ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # message/rfc822 OR text/rfc822-headers part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # message/delivery-status part
            next unless $readcursor & $Indicators->{'deliverystatus'};
            next unless length $e;

            if( grep { index($e, $_) == 0 } @$fieldindex ) {
                # $e matched with any field defined in RFC3464
                $o = Sisimai::RFC1894->field($e);
                $v = $dscontents->[-1];

                if( $o->[-1] eq 'addr' ) {
                    # Final-Recipient: rfc822; kijitora@example.jp
                    # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                    if( $o->[0] eq 'final-recipient' ) {
                        # Final-Recipient: rfc822; kijitora@example.jp
                        if( $v->{'recipient'} ) {
                            # There are multiple recipient addresses in the message body.
                            push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                            $v = $dscontents->[-1];
                        }
                        $v->{'recipient'} = $o->[2];
                        $recipients++;

                    } else {
                        # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                        $v->{'alias'} = $o->[2];
                    }
                } elsif( $o->[-1] eq 'code' ) {
                    # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                    $v->{'spec'} = $o->[1];
                    $v->{'diagnosis'} = $o->[2];

                } else {
                    # Other DSN fields defined in RFC3464
                    next unless exists $fieldtable->{ $o->[0] };
                    $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                    next unless grep { index($e, $_) == 0 } @$mesgfields;
                    $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
                }
            } else {
                # The line does not begin with a DSN field defined in RFC3464
                if( index($p, 'Diagnostic-Code:') == 0 && $e =~ /\A[ \t]+(.+)\z/ ) {
                    # Continued line of the value of Diagnostic-Code field
                    $v->{'diagnosis'} .= ' '.$1;
                }
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'lhost'} ||= $permessage->{'rhost'};
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        SESSION: for my $r ( keys %$ReFailures ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $ReFailures->{ $r };
            $e->{'reason'} = $r;
            last;
        }
    }
    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::Email::MessageLabs - bounce mail parser class for C<MessageLabs>.

=head1 SYNOPSIS

    use Sisimai::Bite::Email::MessageLabs;

=head1 DESCRIPTION

Sisimai::Bite::Email::MessageLabs parses a bounce email which created by C<Symantec.cloud>:
formerly known as C<MessageLabs>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Bite::Email::MessageLabs->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Bite::Email::MessageLabs->smtpagent;

=head2 C<B<scan(I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2018 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

