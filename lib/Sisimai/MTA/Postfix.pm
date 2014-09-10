package Sisimai::MTA::Postfix;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# Postfix manual - bounce(5) - http://www.postfix.org/bounce.5.html
my $RxMTA = {
    'from' => qr/ [(]Mail Delivery System[)]\z/,
    'begin' => [
        qr/\A\s+The Postfix program\z/,
        qr/\A\s+The Postfix on .+ program\z/,   # The Postfix on <os name> program
        qr/\A\s+The \w+ Postfix program\z/,     # The <name> Postfix program
        qr/\A\s+The mail system\z/,
        qr/\AThe \w+ program\z/,                # The <custmized-name> program
        qr/\AThis is the Postfix program/,
        qr/\AThis is the \w+ Postfix program/,  # This is the <name> Postfix program
        qr/\AThis is the \w+ program/,          # This is the <customized-name> Postfix program
        qr/\AThis is the mail system at host/,  # This is the mail system at host <hostname>.
    ],
    'rfc822'  => [
        qr|\AContent-Type: message/rfc822\z|,
        qr|\AContent-Type: text/rfc822-headers\z|,
    ],
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\AUndelivered Mail Returned to Sender\z/,
};

sub version     { '4.0.1' }
sub description { 'Postfix' }
sub smtpagent   { 'Postfix' }

sub scan {
    # @Description  Detect an error from Postfix
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    #  ____           _    __ _      
    # |  _ \ ___  ___| |_ / _(_)_  __
    # | |_) / _ \/ __| __| |_| \ \/ /
    # |  __/ (_) \__ \ |_|  _| |>  < 
    # |_|   \___/|___/\__|_| |_/_/\_\
    #                                
    # Pre-Process email headers and the body part of the message which generated
    # by Postfix e.g.)
    #   From: MAILER-DAEMON (Mail Delivery System)
    #   Subject: Undelivered Mail Returned to Sender
    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};

    my $commandset = [];    # (Ref->Array) ``in reply to * command'' list
    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'    => '',    # The value of Arrival-Date header
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
                # Final-Recipient: RFC822; userunknown@example.jp
                # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                # Action: failed
                # Status: 5.1.1
                # Remote-MTA: DNS; mx.example.jp
                # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\AFinal-Recipient:[ ]*rfc822;[ ]*(.+)\z/ ) {
                    # Final-Recipient: RFC822; userunknown@example.jp
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $recipients++;

                } elsif( $e =~ m/\AX-Actual-Recipient:[ ]*rfc822;[ ]*([^ ]+)\z/ ||
                    $e =~ m/\AOriginal-Recipient:[ ]*rfc822;[ ]*([^ ]+)\z/ ) {
                    # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                    # Original-Recipient: rfc822;kijitora@example.co.jp
                    $v->{'alias'} = $1;

                } elsif( $e =~ m/\AAction:[ ]*(.+)\z/ ) {
                    # Action: failed
                    $v->{'action'} = lc $1;

                } elsif( $e =~ m/\AStatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                    # Status: 5.1.1
                    # Status:5.2.0
                    # Status: 5.1.0 (permanent failure)
                    $v->{'status'} = $1;

                } elsif( $e =~ m/Remote-MTA:[ ]*dns;[ ]*(.+)\z/ ) {
                    # Remote-MTA: DNS; mx.example.jp
                    $v->{'rhost'} = lc $1;

                } elsif( $e =~ m/\ALast-Attempt-Date:[ ]*(.+)\z/ ) {
                    # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                    $v->{'date'} = $1;

                } else {

                    if( $e =~ m/\ADiagnostic-Code:[ ]*(.+?);[ ]*(.+)\z/ ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                        $v->{'spec'} = 'SMTP' if $v->{'spec'} eq 'X-POSTFIX';

                    } elsif( $p =~ m/\ADiagnostic-Code:[ ]*/ && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                # If you do so, please include this problem report. You can
                # delete your own text from the attached returned message.
                #
                #           The mail system
                #
                # <userunknown@example.co.jp>: host mx.example.co.jp[192.0.2.153] said: 550
                # 5.1.1 <userunknown@example.co.jp>... User Unknown (in reply to RCPT TO
                # command)
                if( $e =~ m/\s[(]in reply to .*([A-Z]{4}).*/ ) {
                    # 5.1.1 <userunknown@example.co.jp>... User Unknown (in reply to RCPT TO
                    push @$commandset, $1;

                } elsif( $e =~ m/([A-Z]{4})\s*.*command[)]\z/ ) {
                    # to MAIL command)
                    push @$commandset, $1;

                } else {

                    if( $e =~ m/\AReporting-MTA:[ ]*dns;[ ]*(.+)\z/ ) {
                        # Reporting-MTA: dns; mx.example.jp
                        next if $connheader->{'lhost'};
                        $connheader->{'lhost'} = $1;
                        $connvalues++;

                    } elsif( $e =~ m/\AArrival-Date:[ ]*(.+)\z/ ) {
                        # Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
                        next if $connheader->{'date'};
                        $connheader->{'date'} = $1;
                        $connvalues++;

                    } elsif( $e =~ m/\A(X-Postfix-Sender):[ ]*rfc822;[ ]*(.+)\z/ ) {
                        # X-Postfix-Sender: rfc822; shironeko@example.org
                        $rfc822part .= sprintf( "%s: %s\n", $1, $2 );
                    }
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
        for my $f ( 'date', 'lhost', 'rhost' ) {
            $e->{ $f }  ||= $connheader->{ $f } || '';
        }
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;
        $e->{'command'}   = shift @$commandset || 'CONN';
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        
        if( length( $e->{'status'} ) == 0 || $e->{'status'} =~ m/\A\d[.]0[.]0\z/ ) {
            # There is no value of Status header or the value is 5.0.0, 4.0.0
            my $r = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
            $e->{'status'} = $r if length $r;
        }

    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Postfix - bounce mail parser class for Postfix.

=head1 SYNOPSIS

    use Sisimai::MTA::Postfix;

=head1 DESCRIPTION

Sisimai::MTA::Postfix parses a bounce email which created by Postfix.  Methods 
in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Postfix->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Postfix->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Postfix->smtpagent;

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

