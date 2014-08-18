package Sisimai::MSP::US::AmazonSES;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

# http://aws.amazon.com/ses/
my $RxMSP = {
	'from'    => qr/\AMAILER-DAEMON[@]email[-]bounces[.]amazonses[.]com\z/,
	'begin'   => qr/\AThe following message to [<]/,
	'rfc822'  => qr|\Acontent-type: message/rfc822\z|,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
	'subject' => qr/\ADelivery Status Notification [(]Failure[)]\z/,
};

my $RxErr = {
	'expired' => [
		qr/Delivery expired/,
	],
};

sub version     { '4.0.0' }
sub description { 'AmazonSES: http://aws.amazon.com/ses/' };
sub smtpagent   { 'US::AmazonSES' }
sub headerlist  { return [ 'X-AWS-Outgoing' ] }

sub scan {
    # @Description  Detect an error from Amazon SES
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'x-aws-outgoing'};
    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};
    return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $softbounce = 0;     # (Integer) 1 = Soft bounce
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'rhost'   => '',    # The value of Reporting-MTA header
    };

    my $v = undef;
    my $p = undef;
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::RFC5322;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
        $e =~ s{=\d+\z}{};

        if( ( $e =~ $RxMSP->{'rfc822'} ) .. ( $e =~ $RxMSP->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;

                $previousfn = '';
                next unless grep { lc( $lhs ) eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxMSP->{'begin'} ) .. ( $e =~ $RxMSP->{'rfc822'} );
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Final-Recipient: rfc822;kijitora@example.jp
                # Action: failed
                # Status: 5.0.0 (permanent failure)
                # Remote-MTA: dns; [192.0.2.9]
                # Diagnostic-Code: smtp; 5.1.0 - Unknown address error 550-'5.7.1 
                #  <000001321defbd2a-788e31c8-2be1-422f-a8d4-cf7765cc9ed7-000000@email-bounces.amazonses.com>...
                #  Access denied' (delivery attempts: 0)
                #
                # --JuU8e.4gyIcCrxq.1RFbQY.3Vu7Hs+
                # content-type: message/rfc822
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\AFinal-Recipient:[ ]*rfc822;[ ]*([^ ]+)\z/i ) {
                    # Final-Recipient: RFC822; userunknown@example.jp
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $recipients++;

                } elsif( $e =~ m/\AX-Actual-Recipient:[ ]*rfc822;[ ]*([^ ]+)\z/i ) {
                    # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                    $v->{'alias'} = $1;

                } elsif( $e =~ m/\AAction:[ ]*(.+)\z/i ) {
                    # Action: failed
                    $v->{'action'} = lc $1;

                } elsif( $e =~ m/\AStatus:[ ]*(\d[.]\d+[.]\d+)/i ) {
                    # Status: 5.1.1
                    # Status:5.2.0
                    # Status: 5.1.0 (permanent failure)
                    $v->{'status'} = $1;
                    $softbounce = 0 if $e =~ m/[(]permanent failure[)]/;

                } elsif( $e =~ m/\ARemote-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                    # Remote-MTA: DNS; mx.example.jp
                    $v->{'rhost'} = lc $1;

                } elsif( $e =~ m/\ALast-Attempt-Date:[ ]*(.+)\z/i ) {
                    # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                    $v->{'date'} = $1;

                } else {

                    if( $e =~ m/\ADiagnostic-Code:[ ]*(.+?);[ ]*(.+)\z/i ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                    } elsif( $p =~ m/\ADiagnostic-Code:[ ]*/i && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                # The following message to <kijitora@example.jp> was undeliverable.
                # The reason for the problem:
                # 5.1.0 - Unknown address error 550-'5.7.1 <0000000000000000-00000000-0000-00=
                # 00-0000-000000000000-000000@email-bounces.amazonses.com>... Access denied'
                #
                # --JuU8e.4gyIcCrxq.1RFbQY.3Vu7Hs+
                # content-type: message/delivery-status
                #
                # Reporting-MTA: dns; a192-79.smtp-out.amazonses.com
                #
                if( $e =~ m/\AReporting-MTA:[ ]*dns;[ ]*(.+)\z/ ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if length $connheader->{'rhost'};
                    $connheader->{'rhost'} = $1;
                    $connvalues++;
                }
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = undef;
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'date'} ||= $mhead->{'date'};

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
            PATTERN: for my $rr ( @{ $RxErr->{ $r } } ) {
                # Check each regular expression
                next unless $e->{'diagnosis'} =~ $rr;
                $e->{'reason'} = $r;
                last(SESSION);
            }
        }

        $e->{'reason'}  ||= Sisimai::RFC3463->reason( $e->{'status'} );
        $e->{'spec'}    ||= 'SMTP';
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::AmazonSES - bounce mail parser class for Amazon SES.

=head1 SYNOPSIS

    use Sisimai::MSP::US::AmazonSES;

=head1 DESCRIPTION

Sisimai::MSP::US::AmazonSES parses a bounce email which created by Amazon SES.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::US::AmazonSES->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::AmazonSES->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::AmazonSES->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
