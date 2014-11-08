package Sisimai::MSP::US::Facebook;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'    => qr/\AFacebook [<]mailer-daemon[@]mx[.]facebook[.]com[>]\z/,
    'begin'   => qr/\AThis message was created automatically by Facebook[.]\z/,
    'rfc822'  => qr/\AContent-Disposition: inline\z/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\ASorry, your message could not be delivered\z/,
};

# http://postmaster.facebook.com/response_codes
# NOT TESTD EXCEPT RCP-P2
my $RxErr = {
    'userunknown' => [
        'RCP-P1',   # The attempted recipient address does not exist.
        'INT-P1',   # The attempted recipient address does not exist.
        'INT-P3',   # The attempted recpient group address does not exist.
        'INT-P4',   # The attempted recipient address does not exist.
    ],
    'filtered' => [
        'RCP-P2',   # The attempted recipient's preferences prevent messages from being delivered.
    ],
    'mesgtoobig' => [
        'MSG-P1',   # The message exceeds Facebook's maximum allowed size.
        'INT-P2',   # The message exceeds Facebook's maximum allowed size.
    ],
    'contenterror' => [
        'MSG-P2',   # The message contains an attachment type that Facebook does not accept.
        'POL-P6',   # The message contains a url that has been blocked by Facebook.
    ],
    'securityerror' => [
        'POL-P1',   # Your mail server's IP Address is listed on the Spamhaus PBL.
        'POL-P2',   # Facebook will no longer accept mail from your mail server's IP Address.
        'POL-P5',   # The message contains a virus.
        'POL-P7',   # The message does not comply with Facebook's Domain Authentication requirements.
    ],
    'notaccept' => [
        'POL-P3',   # Facebook is not accepting messages from your mail server. This will persist for 4 to 8 hours.
        'POL-P4',   # Facebook is not accepting messages from your mail server. This will persist for 24 to 48 hours.
        'POL-T1',   # Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 1 to 2 hours.
        'POL-T2',   # Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 4 to 8 hours.
        'POL-T3',   # Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 24 to 48 hours.
    ],
    'rejected' => [
        'DNS-P1',   # Your SMTP MAIL FROM domain does not exist.
        'DNS-P2',   # Your SMTP MAIL FROM domain does not have an MX record.
        'DNS-T1',   # Your SMTP MAIL FROM domain exists but does not currently resolve.
        'DNS-P3',   # Your mail server does not have a reverse DNS record.
        'DNS-T2',   # You mail server's reverse DNS record does not currently resolve.
    ],
    'systemerror' => [
        'CON-T1',   # Facebook's mail server currently has too many connections open to allow another one.
    ],
    'undefined' => [
        'RCP-T1',   # The attempted recipient address is not currently available due to an internal system issue. This is a temporary condition.
        'MSG-T1',   # The number of recipients on the message exceeds Facebook's allowed maximum.
        'CON-T2',   # Your mail server currently has too many connections open to Facebook's mail servers.
        'CON-T3',   # Your mail server has opened too many new connections to Facebook's mail servers in a short period of time.
        'CON-T4',   # Your mail server has exceeded the maximum number of recipients for its current connection.
    ],
};

sub version     { '4.0.6' }
sub description { 'Facebook' }
sub smtpagent   { 'US::Facebook' }

sub scan {
    # @Description  Detect an error from Facebook
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};
    return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $fbresponse = '';    # (String) Response code from Facebook
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'    => '',    # The value of Arrival-Date header
        'rhost'   => '',    # The value of Reporting-MTA header
    };

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
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
                next if $rfc822next->{ lc $previousfn };
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;

            } else {
                # Check the end of headers in rfc822 part
                next unless $previousfn =~ m/\A(?:From|To|Subject)\z/;
                next unless $e =~ m/\A\z/;
                $rfc822next->{ lc $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxMSP->{'begin'} ) .. ( $e =~ $RxMSP->{'rfc822'} );
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Reporting-MTA: dns; 10.138.205.200
                # Arrival-Date: Thu, 23 Jun 2011 02:29:43 -0700
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

                } elsif( $e =~ m/\AX-Actual-Recipient:[ ]*rfc822;[ ]*(.+)\z/i ) {
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

                } elsif( $e =~ m/Remote-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                    # Remote-MTA: DNS; mx.example.jp
                    $v->{'rhost'} = lc $1;

                } elsif( $e =~ m/\ALast-Attempt-Date:[ ]*(.+)\z/i ) {
                    # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                    $v->{'date'} = $1;

                } else {

                    if( $e =~ m/\ADiagnostic-Code:[ ]*(.+?);[ ]*(.+)\z/i ) {
                        # Diagnostic-Code: smtp; 550 5.1.1 RCP-P2 
                        #     http://postmaster.facebook.com/response_codes?ip=192.0.2.135#rcp Refused due to recipient preferences
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                    } elsif( $p =~ m/\ADiagnostic-Code:[ ]*/i && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                if( $e =~ m/\AReporting-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if $connheader->{'rhost'};
                    $connheader->{'rhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\AArrival-Date:[ ]*(.+)\z/i ) {
                    # Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
                    next if $connheader->{'date'};
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
        $e->{'agent'} ||= __PACKAGE__->smtpagent;
        $e->{'rhost'} ||= $connheader->{'rhost'};

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( $e->{'diagnosis'} =~ m/\b([A-Z]{3})[-]([A-Z])(\d)\b/ ) {
            # Diagnostic-Code: smtp; 550 5.1.1 RCP-P2 
            my $lhs = $1;
            my $rhs = $2;
            my $num = $3;

            $fbresponse = sprintf( "%s-%s%d", $lhs, $rhs, $num );
            $e->{'softbounce'} = $rhs eq 'P' ? 0 : 1;
        }

        SESSION: for my $r ( keys %$RxErr ) {
            # Verify each regular expression of session errors
            PATTERN: for my $rr ( @{ $RxErr->{ $r } } ) {
                # Check each regular expression
                next(PATTERN) unless $fbresponse eq $rr;
                $e->{'reason'} = $r;
                last(SESSION);
            }
        }

        unless( $e->{'reason'} ) {
            # http://postmaster.facebook.com/response_codes
            #   Facebook System Resource Issues
            #   These codes indicate a temporary issue internal to Facebook's 
            #   system. Administrators observing these issues are not required to
            #   take any action to correct them.
            if( $fbresponse =~ m/\AINT-T\d+\z/ ) {
                # * INT-Tx
                #
                # https://groups.google.com/forum/#!topic/cdmix/eXfi4ddgYLQ
                # This block has not been tested because we have no email sample
                # including "INT-T?" error code.
                $e->{'reason'} = 'systemerror';
                $e->{'softbounce'} = 1;
            }
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Facebook - bounce mail parser class for Facebook.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Facebook;

=head1 DESCRIPTION

Sisimai::MSP::US::Facebook parses a bounce email which created by Facebook.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::US::Facebook->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::Facebook->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::Facebook->smtpagent;

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
