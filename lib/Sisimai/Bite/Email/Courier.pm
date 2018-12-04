package Sisimai::Bite::Email::Courier;
use parent 'Sisimai::Bite::Email';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    # http://www.courier-mta.org/courierdsn.html
    # courier/module.dsn/dsn*.txt
    'message' => ['DELAYS IN DELIVERING YOUR MESSAGE', 'UNDELIVERABLE MAIL'],
    'rfc822'  => ['Content-Type: message/rfc822', 'Content-Type: text/rfc822-headers'],
};

my $MessagesOf = {
    # courier/module.esmtp/esmtpclient.c:526| hard_error(del, ctf, "No such domain.");
    'hostunknown' => ['No such domain.'],
    # courier/module.esmtp/esmtpclient.c:531| hard_error(del, ctf,
    # courier/module.esmtp/esmtpclient.c:532|  "This domain's DNS violates RFC 1035.");
    'systemerror' => ["This domain's DNS violates RFC 1035."],
    # courier/module.esmtp/esmtpclient.c:535| soft_error(del, ctf, "DNS lookup failed.");
    'networkerror'=> ['DNS lookup failed.'],
};

sub description { 'Courier MTA' }
sub scan {
    # Detect an error from Courier MTA
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
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match ||= 1 if index($mhead->{'from'}, 'Courier mail server at ') > -1;
    $match ||= 1 if $mhead->{'subject'} =~ /(?:NOTICE: mail delivery status[.]|WARNING: delayed mail[.])/;
    if( defined $mhead->{'message-id'} ) {
        # Message-ID: <courier.4D025E3A.00001792@5jo.example.org>
        $match ||= 1 if $mhead->{'message-id'} =~ /\A[<]courier[.][0-9A-F]+[.]/;
    }
    return undef unless $match;

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $v = undef;
    my $p = '';

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            if( rindex($e, $StartingOf->{'message'}->[0]) > -1 ||
                rindex($e, $StartingOf->{'message'}->[1]) > -1 ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part(message/rfc822)
            if( index($e, $StartingOf->{'rfc822'}->[0]) == 0 ||
                index($e, $StartingOf->{'rfc822'}->[1]) == 0 ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # message/rfc822 or text/rfc822-headers part
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
                my $o = Sisimai::RFC1894->field($e) || next;
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
                #
                # This is a delivery status notification from marutamachi.example.org,
                # running the Courier mail server, version 0.65.2.
                #
                # The original message was received on Sat, 11 Dec 2010 12:19:57 +0900
                # from [127.0.0.1] (c10920.example.com [192.0.2.20])
                # 
                # ---------------------------------------------------------------------------
                #
                #                           UNDELIVERABLE MAIL
                #
                # Your message to the following recipients cannot be delivered:
                #
                # <kijitora@example.co.jp>:
                #    mx.example.co.jp [74.207.247.95]:
                # >>> RCPT TO:<kijitora@example.co.jp>
                # <<< 550 5.1.1 <kijitora@example.co.jp>... User Unknown
                #
                # ---------------------------------------------------------------------------
                if( $e =~ /\A[>]{3}[ ]+([A-Z]{4})[ ]?/ ) {
                    # >>> DATA
                    $commandtxt ||= $1;

                } else {
                    # Continued line (Folded)
                    if( index($p, 'Diagnostic-Code:') == 0 && $e =~ /\A[ \t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code field
                        $v->{'diagnosis'} .= ' '.$1;
                    }
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
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        for my $r ( keys %$MessagesOf ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } @{ $MessagesOf->{ $r } };
            $e->{'reason'} = $r;
            last;
        }
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'command'} ||= $commandtxt || '';
    }

    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::Email::Courier - bounce mail parser class for C<Courier MTA>.

=head1 SYNOPSIS

    use Sisimai::Bite::Email::Courier;

=head1 DESCRIPTION

Sisimai::Bite::Email::Courier parses a bounce email which created by C<Courier MTA>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Bite::Email::Courier->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Bite::Email::Courier->smtpagent;

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
