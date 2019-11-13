package Sisimai::Lhost::Zoho;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['This message was created automatically by mail delivery'],
    'rfc822'  => ['from mail.zoho.com by mx.zohomail.com'],
};
my $MessagesOf = { 'expired' => ['Host not reachable'] };

# X-ZohoMail: Si CHF_MF_NL SS_10 UW48 UB48 FMWL UW48 UB48 SGR3_1_09124_42
# X-Zoho-Virus-Status: 2
# X-Mailer: Zoho Mail
sub headerlist  { return ['x-zohomail'] }
sub description { 'Zoho Mail: https://www.zoho.com' }
sub make {
    # Detect an error from Zoho Mail
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
    # @since v4.1.7
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    # 'from'     => qr/mailer-daemon[@]mail[.]zoho[.]com\z/,
    # 'subject'  => qr/\A(?:Undelivered Mail Returned to Sender|Mail Delivery Status Notification)/x,
    # 'x-mailer' => qr/\AZoho Mail\z/,
    return undef unless $mhead->{'x-zohomail'};

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $qprintable = 0;
    my $v = undef;

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( index($e, $StartingOf->{'message'}->[0]) == 0 ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( rindex($e, $StartingOf->{'rfc822'}->[0]) > -1 ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Inside of the original message part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # Error meesage part
            next unless $readcursor & $Indicators->{'deliverystatus'};
            next unless length $e;

            # This message was created automatically by mail delivery software.
            # A message that you sent could not be delivered to one or more of its recip=
            # ients. This is a permanent error.=20
            #
            # kijitora@example.co.jp Invalid Address, ERROR_CODE :550, ERROR_CODE :5.1.=
            # 1 <kijitora@example.co.jp>... User Unknown

            # This message was created automatically by mail delivery software.
            # A message that you sent could not be delivered to one or more of its recipients. This is a permanent error. 
            #
            # shironeko@example.org Invalid Address, ERROR_CODE :550, ERROR_CODE :Requested action not taken: mailbox unavailable
            $v = $dscontents->[-1];

            if( $e =~ /\A([^ ]+[@][^ ]+)[ \t]+(.+)\z/ ) {
                # kijitora@example.co.jp Invalid Address, ERROR_CODE :550, ERROR_CODE :5.1.=
                if( $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[-1];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $2;

                if( substr($v->{'diagnosis'}, -1, 1) eq '=' ) {
                    # Quoted printable
                    substr($v->{'diagnosis'}, -1, 1, '');
                    $qprintable = 1;
                }
                $recipients++;

            } elsif( $e =~ /\A\[Status: .+[<]([^ ]+[@][^ ]+)[>],/ ) {
                # Expired
                # [Status: Error, Address: <kijitora@6kaku.example.co.jp>, ResponseCode 421, , Host not reachable.]
                if( $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[-1];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $e;
                $recipients++;

            } else {
                # Continued line
                next unless $qprintable;
                $v->{'diagnosis'} .= $e;
            }
        } # End of error message part
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'agent'}     =  __PACKAGE__->smtpagent;
        $e->{'diagnosis'} =~ y/\n/ /;
        $e->{'diagnosis'} =  Sisimai::String->sweep($e->{'diagnosis'});

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

Sisimai::Lhost::Zoho - bounce mail parser class for C<Zoho Mail>.

=head1 SYNOPSIS

    use Sisimai::Lhost::Zoho;

=head1 DESCRIPTION

Sisimai::Lhost::Zoho parses a bounce email which created by C<Zoho! MAIL>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Zoho->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::Zoho->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

