package Sisimai::MTA::Courier;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# http://www.courier-mta.org/courierdsn.html
# courier/module.dsn/dsn*.txt
my $RxMTA = {
    #'from' => qr{Courier mail server at },
    'begin' => [
        qr/DELAYS IN DELIVERING YOUR MESSAGE/,
        qr/UNDELIVERABLE MAIL/,
    ],
    'rfc822'  => [
        qr|\AContent-Type: message/rfc822\z|,
        qr|\AContent-Type: text/rfc822-headers\z|,
    ],
    'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => [
        qr/NOTICE: mail delivery status[.]/,
        qr/WARNING: delayed mail[.]/,
    ],
};

sub version     { '4.0.0' }
sub description { 'Courier MTA' }
sub smtpagent   { 'Courier' }

sub scan {
    # @Description  Detect an error from Courier MTA
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless grep { $mhead->{'subject'} =~ $_ } @{ $RxMTA->{'subject'} };
    # return undef unless( defined $mhead->{'message-id'} );
    # return undef unless( $mhead->{'message-id'} =~ $RxMTA->{'message-id'} );

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'    => '',    # The value of Arrival-Date header
        'rhost'   => '',    # The value of Reporting-MTA header
        'lhost'   => '',    # The value of Received-From-MTA header
    };

    my $v = undef;
    my $p = undef;
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        if( ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
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
            next unless ( grep { $e =~ $_ } @{ $RxMTA->{'begin'} } ) .. ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } );
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Final-Recipient: rfc822; kijitora@example.co.jp
                # Action: failed
                # Status: 5.0.0
                # Remote-MTA: dns; mx.example.co.jp [192.0.2.95]
                # Diagnostic-Code: smtp; 550 5.1.1 <kijitora@example.co.jp>... User Unknown
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\AFinal-Recipient:[ ]*rfc822;[ ]*([^ ]+)\z/i ) {
                    # Final-Recipient: rfc822; kijitora@example.co.jp
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

                } elsif( $e =~ m/Remote-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
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
                if( $e =~ m/\A[>]{3}[ ]+([A-Z]{4})[ ]?/ ) {
                    # >>> DATA
                    next if $connheader->{'command'};
                    next if $commandtxt;
                    $commandtxt = $1;

                } elsif( $e =~ m/\AReporting-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if $connheader->{'rhost'};
                    $connheader->{'rhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\AReceived-From-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                    # Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
                    next if $connheader->{'lhost'};
                    $connheader->{'lhost'} = $1;
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
        $e = undef;
    }

    return undef unless $recipients;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        for my $f ( 'date', 'lhost', 'rhost' ) {
            $e->{ $f }  ||= $connheader->{ $f } || '';
        }

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        
        if( ! $e->{'status'} || $e->{'status'} =~ m/\d[.]0[.]0\z/ ) {
            # Get the status code from the respnse of remote MTA.
            my $f = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
            $e->{'status'} = $f if length $f;
        }
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;
        $e->{'command'} ||= $commandtxt || 'CONN';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Courier - bounce mail parser class for Courier MTA.

=head1 SYNOPSIS

    use Sisimai::MTA::Courier;

=head1 DESCRIPTION

Sisimai::MTA::Courier parses a bounce email which created by Courier MTA.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Courier->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Courier->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Courier->smtpagent;

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
