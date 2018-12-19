package Sisimai::Bite::Email::Yandex;
use parent 'Sisimai::Bite::Email';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['This is the mail system at host yandex.ru.'],
    'rfc822'  => ['Content-Type: message/rfc822'],
};

# X-Yandex-Front: mxback1h.mail.yandex.net
# X-Yandex-TimeMark: 1417885948
# X-Yandex-Uniq: 92309766-f1c8-4bd4-92bc-657c75766587
# X-Yandex-Spam: 1
# X-Yandex-Forward: 10104c00ad0726da5f37374723b1e0c8
# X-Yandex-Queue-ID: 367D79E130D
# X-Yandex-Sender: rfc822; shironeko@yandex.example.com
sub headerlist  { return ['x-yandex-uniq'] }
sub description { 'Yandex.Mail: http://www.yandex.ru' }
sub scan {
    # Detect an error from Yandex.Mail
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
    # @since v4.1.6
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'x-yandex-uniq'};
    return undef unless $mhead->{'from'} eq 'mailer-daemon@yandex.ru';

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my @commandset = ();    # (Array) ``in reply to * command'' list
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
            if( index($e, $StartingOf->{'rfc822'}->[0]) == 0 ) {
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
                # The line does not begin with a DSN field defined in RFC3464
                # <kijitora@example.jp>: host mx.example.jp[192.0.2.153] said: 550
                #    5.1.1 <kijitora@example.jp>... User Unknown (in reply to RCPT TO
                #    command)
                if( $e =~ /[ \t][(]in reply to .*([A-Z]{4}).*/ ) {
                    # 5.1.1 <userunknown@example.co.jp>... User Unknown (in reply to RCPT TO
                    push @commandset, $1;

                } elsif( $e =~ /([A-Z]{4})[ \t]*.*command[)]\z/ ) {
                    # to MAIL command)
                    push @commandset, $1;

                } else {
                    # Continued line of the value of Diagnostic-Code field
                    next unless index($p, 'Diagnostic-Code:') == 0;
                    next unless $e =~ /\A[ \t]+(.+)\z/;
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
        $e->{'lhost'}    ||= $permessage->{'rhost'};
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'command'}   =  shift @commandset || '';
        $e->{'diagnosis'} =~ s/\\n/ /g;
        $e->{'diagnosis'} =  Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'agent'}     =  __PACKAGE__->smtpagent;
    }
    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::Email::Yandex - bounce mail parser class for C<Yandex.Mail>.

=head1 SYNOPSIS

    use Sisimai::Bite::Email::Yandex;

=head1 DESCRIPTION

Sisimai::Bite::Email::Yandex parses a bounce email which created by C<Yandex.Mail>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Bite::Email::Yandex->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Bite::Email::Yandex->smtpagent;

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


