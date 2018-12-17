package Sisimai::Bite::Email::Outlook;
use parent 'Sisimai::Bite::Email';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['This is an automatically generated Delivery Status Notification'],
    'rfc822'  => ['Content-Type: message/rfc822'],
};
my $MessagesOf = {
    'hostunknown' => ['The mail could not be delivered to the recipient because the domain is not reachable'],
    'userunknown' => ['Requested action not taken: mailbox unavailable'],
};

# X-Message-Delivery: Vj0xLjE7RD0wO0dEPTA7U0NMPTk7bD0xO3VzPTE=
# X-Message-Info: AuEzbeVr9u5fkDpn2vR5iCu5wb6HBeY4iruBjnutBzpStnUabbM...
sub headerlist  { return ['X-Message-Delivery', 'X-Message-Info'] }
sub description { 'Microsoft Outlook.com: https://www.outlook.com/' }
sub scan {
    # Detect an error from Microsoft Outlook.com
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
    # @since v4.1.3
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # 'from'     => qr/postmaster[@]/,
    $match++ if index($mhead->{'subject'}, 'Delivery Status Notification') > -1;
    $match++ if $mhead->{'x-message-delivery'};
    $match++ if $mhead->{'x-message-info'};
    $match++ if grep { rindex($_, '.hotmail.com') > -1 } @{ $mhead->{'received'} };
    return undef if $match < 2;

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;
    my $p = '';

    for my $e ( split("\n", $$mbody) ) {
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

            if( my $f = Sisimai::RFC1894->match($e) ) {
                # $e matched with any field defined in RFC3464
                next unless my $o = Sisimai::RFC1894->field($e);
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

                    next unless $f == 1;
                    $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
                }
            } else {
                # Continued line of the value of Diagnostic-Code field
                next unless index($p, 'Diagnostic-Code:') == 0;
                next unless $e =~ /\A[ \t]+(.+)\z/;
                $v->{'diagnosis'} .= ' '.$1;
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'lhost'}    ||= $permessage->{'rhost'};
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'agent'}      = __PACKAGE__->smtpagent;
        $e->{'diagnosis'}  = Sisimai::String->sweep($e->{'diagnosis'});

        unless( $e->{'diagnosis'} ) {
            # No message in 'diagnosis'
            if( $e->{'action'} eq 'delayed' ) {
                # Set pseudo diagnostic code message for delaying
                $e->{'diagnosis'} = 'Delivery to the following recipients has been delayed.';

            } else {
                # Set pseudo diagnostic code message
                $e->{'diagnosis'}  = 'Unable to deliver message to the following recipients, ';
                $e->{'diagnosis'} .= 'due to being unable to connect successfully to the destination mail server.';
            }
        }

        SESSION: for my $r ( keys %$MessagesOf ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } @{ $MessagesOf->{ $r } };
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

Sisimai::Bite::Email::Outlook - bounce mail parser class for C<Outlook.com>.

=head1 SYNOPSIS

    use Sisimai::Bite::Email::Outlook;

=head1 DESCRIPTION

Sisimai::Bite::Email::Outlook parses a bounce email which created by C<Microsoft Outlook.com>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Bite::Email::Outlook->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Bite::Email::Outlook->smtpagent;

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

