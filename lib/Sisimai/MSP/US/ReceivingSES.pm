package Sisimai::MSP::US::ReceivingSES;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

# http://aws.amazon.com/ses/
my $RxMSP = {
    'begin'   => qr/\AThis message could not be delivered[.]\z/,
    'rfc822'  => qr|\Acontent-type: text/rfc822-headers\z|,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\ADelivery Status Notification [(]Failure[)]\z/,
    'received'=> qr/.+[.]smtp-out[.].+[.]amazonses[.]com\b/,
};

my $RxErr = {
    # The followings are error messages in Rule sets/*/Actions/Template
    'filtered'      => qr/Mailbox does not exist/,
    'mesgtoobig'    => qr/Message too large/,
    'mailboxfull'   => qr/Mailbox full/,
    'contenterror'  => qr/Message content rejected/,
};

sub description { 'AmazonSES(Receiving): http://aws.amazon.com/ses/' };
sub smtpagent   { 'US::ReceivingSES' }
sub headerlist  { return [ 'X-SES-Outgoing', 'Feedback-ID' ] }

sub scan {
    # Detect an error from Amazon SES/Receiving
    # @param         [Hash] mhead       Message header of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.1.29
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};
    return undef unless $mhead->{'x-ses-outgoing'};
    return undef unless $mhead->{'feedback-id'};
    return undef unless grep { $_ =~ $RxMSP->{'received'} } @{ $mhead->{'received'} };

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $indicators = __PACKAGE__->INDICATORS;

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'  => '',      # The value of Arrival-Date header
        'rhost' => '',      # The value of Reporting-MTA header
    };

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
        $e =~ s{=\d+\z}{};

        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor |= $indicators->{'deliverystatus'} if $e =~ $RxMSP->{'begin'};
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor |= $indicators->{'message-rfc822'} if $e =~ $RxMSP->{'rfc822'};
        }

        if( $readcursor & $indicators->{'message-rfc822'} ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $whs = lc $lhs;

                $previousfn = '';
                next unless grep { $whs eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ lc $previousfn };
                $rfc822part .= $e."\n" if grep { $previousfn eq $_ } @$longfields;

            } else {
                # Check the end of headers in rfc822 part
                next unless grep { $previousfn eq $_ } @$longfields;
                next if length $e;
                $rfc822next->{ lc $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless $readcursor & $indicators->{'deliverystatus'};
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Action: failed
                # Final-Recipient: rfc822; kijitora@neko.example.jp
                # Original-Recipient: rfc822; kijitora@neko.example.jp
                # Diagnostic-Code: smtp; 550 5.1.1 Mailbox does not exist
                # Status: 5.1.1
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # Final-Recipient: RFC822; kijitora@example.jp
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $recipients++;

                } elsif( $e =~ m/\A[Xx]-[Aa]ctual-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ||
                         $e =~ m/\A[Oo]riginal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                    # Original-Recipient: rfc822; kijitora@example.co.jp
                    $v->{'alias'} = $1;

                } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                    # Action: failed
                    $v->{'action'} = lc $1;

                } elsif( $e =~ m/\A[Ss]tatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                    # Status: 5.1.1
                    $v->{'status'} = $1;

                } elsif( $e =~ m/\A[Rr]emote-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Remote-MTA: DNS; mx.example.jp
                    $v->{'rhost'} = lc $1;

                } elsif( $e =~ m/\A[Ll]ast-[Aa]ttempt-[Dd]ate:[ ]*(.+)\z/ ) {
                    # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                    $v->{'date'} = $1;

                } else {

                    if( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <kijitora@example.jp>... User Unknown
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                    } elsif( $p =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*/ && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                # This message could not be delivered.
                # ------=_Part_0_1984813963.1443707337938
                # Content-Type: message/delivery-status
                # Content-Transfer-Encoding: 7bit
                # Content-Description: Delivery Status Notification
                #
                # Reporting-MTA: dns; inbound-smtp.us-west-2.amazonaws.com
                if( $e =~ m/\A[Rr]eporting-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if length $connheader->{'rhost'};
                    $connheader->{'rhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A[Aa]rrival-[Dd]ate:[ ]*(.+)\z/ ) {
                    # Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
                    next if length $connheader->{'date'};
                    $connheader->{'date'} = $1;
                    $connvalues++;
                }
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        map { $e->{ $_ } ||= $connheader->{ $_ } || '' } keys %$connheader;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'diagnosis'} =~ s{\\n}{ }g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        if( $e->{'status'} =~ m/\A[45][.][01][.]0\z/ ) {
            # Get other D.S.N. value from the error message
            my $r = '';
            my $x = $e->{'diagnosis'};

            if( $e->{'diagnosis'} =~ m/["'](\d[.]\d[.]\d.+)['"]/ ) {
                # 5.1.0 - Unknown address error 550-'5.7.1 ...
                $x = $1;
            }

            $r = Sisimai::RFC3463->getdsn( $x );
            $e->{'status'} = $r if length $r;
        }

        SESSION: for my $r ( keys %$RxErr ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $RxErr->{ $r };
            $e->{'reason'} = $r;
            last;
        }

        $e->{'reason'} ||= Sisimai::RFC3463->reason( $e->{'status'} );
        $e->{'spec'}   ||= 'SMTP';
        $e->{'agent'}    = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::ReceivingSES - bounce mail parser class for C<Amazon SES>.

=head1 SYNOPSIS

    use Sisimai::MSP::US::ReceivingSES;

=head1 DESCRIPTION

Sisimai::MSP::US::ReceivingSES parses a bounce email which created by C<Amazon
Simple Email Service>. Methods in the module are called from only 
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::ReceivingSES->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::ReceivingSES->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

