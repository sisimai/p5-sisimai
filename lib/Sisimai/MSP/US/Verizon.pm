package Sisimai::MSP::US::Verizon;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'received' => qr/by .+[.]vtext[.]com /,
    'vtext.com' => {
        'from' => qr/\Apost_master[@]vtext[.]com\z/,
    },
    'vzwpix.com' => {
        'from'    => qr/[<]?sysadmin[@].+[.]vzwpix[.]com[>]?\z/,
        'subject' => qr/Undeliverable Message/,
    },
};

sub version     { '4.0.0' }
sub description { 'Verizon Wireless' }
sub smtpagent   { 'US::Verizon' }

sub scan {
    # @Description  Detect an error from Verizon
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $vtext = undef;

    while(1) {
        # Check the value of "From" header
        last unless grep { $_ =~ $RxMSP->{'received'} } @{ $mhead->{'received'} };
        $vtext = 1 if $mhead->{'from'} =~ $RxMSP->{'vtext.com'}->{'from'};
        $vtext = 0 if $mhead->{'from'} =~ $RxMSP->{'vzwpix.com'}->{'from'};
        last;
    }
    return undef unless defined $vtext;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $senderaddr = '';    # (String) Sender address in the message body
    my $subjecttxt = '';    # (String) Subject of the original message
    my $softbounce = 0;     # (Integer) 1 = Soft bounce

    my $RxMTA      = {};    # (Ref->Hash) Delimiter patterns
    my $RxErr      = {};    # (Ref->Hash) Error message patterns
    my $boundary00 = '';    # (String) Boundary string

    my $v = undef;
    my $p = undef;
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::MIME;
    require Sisimai::Address;

    if( $vtext == 1 ) {
        # vtext.com
        $RxMTA = {
            'begin'  => qr/\AError:\s/,
            'rfc822' => qr/\A__BOUNDARY_STRING_HERE__\z/,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $RxErr = {
            'userunknown' => [
                # The attempted recipient address does not exist.
                qr/550 - Requested action not taken: no such user here/,
            ],
        };

        $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
        $RxMTA->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;

        for my $e ( @$stripedtxt ) {
            # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
            if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
                # After "message/rfc822"
                if( $e =~ m/\A\s\s([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
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
                next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
                next unless length $e;

                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A\s+RCPT TO: (.*)\z/ ) {
                    # Message details:
                    #   Subject: Test message
                    #   Sent date: Wed Jun 12 02:21:53 GMT 2013
                    #   MAIL FROM: *******@hg.example.com
                    #   RCPT TO: *****@vtext.com
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }

                    $v->{'recipient'} = $1;
                    $recipients++;
                    next;

                } elsif( $e =~ m/\A\s+MAIL FROM:\s(.+)\z/ ) {
                    #   MAIL FROM: *******@hg.example.com
                    $senderaddr ||= $1;

                } elsif( $e =~ m/\A\s+Subject:\s(.+)\z/ ) {
                    #   Subject:
                    $subjecttxt ||= $1;

                } else {

                    if( $e =~ m/\A(\d{3})\s[-]\s(.*)\z/ ) {
                        # 550 - Requested action not taken: no such user here
                        $v->{'diagnosis'} = $e;
                    }
                }
            } # End of if: rfc822

        } continue {
            # Save the current line for the next loop
            $p = $e;
            $e = undef;
        }

    } else {
        # vzwpix.com
        $RxMTA = {
            'begin'  => qr/\AMessage could not be delivered to mobile/,
            'rfc822' => qr/\A__BOUNDARY_STRING_HERE__\z/,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $RxErr = {
            'userunknown' => [
                qr/No valid recipients for this MM/
            ],
        };

        $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
        $RxMTA->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;

        for my $e ( @$stripedtxt ) {
            # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
            if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
                # After "message/rfc822"
                if( $e =~ m/\A\s\s([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
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
                next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
                next unless length $e;

                $v = $dscontents->[ -1 ];

                if( $e =~ m/\ATo:\s+(.*)\z/ ) {
                    # Original Message:
                    # From: kijitora <kijitora@example.jp>
                    # To: 0000000000@vzwpix.com
                    # Subject: test for bounce
                    # Date:  Wed, 20 Jun 2013 10:29:52 +0000
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }

                    $v->{'recipient'} = Sisimai::Address->s3s4( $1 );
                    $recipients++;
                    next;

                } elsif( $e =~ m/\AFrom:\s(.+)\z/ ) {
                    # From: kijitora <kijitora@example.jp>
                    $senderaddr ||= Sisimai::Address->s3s4( $1 );

                } elsif( $e =~ m/\ASubject:\s(.+)\z/ ) {
                    #   Subject:
                    $subjecttxt ||= $1;

                } else {

                    if( $e =~ m/\AError:\s+(.+)\z/ ) {
                        # Message could not be delivered to mobile.
                        # Error: No valid recipients for this MM
                        $v->{'diagnosis'} = $e;
                    }
                }
            } # End of if: rfc822

        } continue {
            # Save the current line for the next loop
            $p = $e;
            $e = undef;
        }
    }

    return undef unless $recipients;

    # Set the value of "MAIL FROM:" or "From:", and "Subject"
    $rfc822part .= sprintf( "From: %s\n", $senderaddr ) unless $rfc822part =~ m/\bFrom: /;
    $rfc822part .= sprintf( "Subject: %s\n", $subjecttxt ) unless $rfc822part =~ m/\bSubject: /;

    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'date'}  ||= $mhead->{'date'};
        $e->{'agent'} ||= __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        chomp $e->{'diagnosis'};
        $e->{'diagnosis'} =~ y{ }{}s;
        $e->{'diagnosis'} =~ s{\A }{}g;
        $e->{'diagnosis'} =~ s{ \z}{}g;
        $e->{'diagnosis'} =~ s{ [-]{2,}.+\z}{};

        SESSION: for my $r ( keys %$RxErr ) {
            # Verify each regular expression of session errors
            PATTERN: for my $rr ( @{ $RxErr->{ $r } } ) {
                # Check each regular expression
                next(PATTERN) unless $e->{'diagnosis'} =~ $rr;
                $e->{'reason'} = $r;
                last(SESSION);
            }
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        STATUS_CODE: while(1) {
            last if length $e->{'status'};

            if( $e->{'reason'} ) {
                # Set pseudo status code
                $softbounce = 1 if Sisimai::RFC3463->is_softbounce( $e->{'diagnosis'} );
                my $s = $softbounce ? 't' : 'p';
                my $r = Sisimai::RFC3463->status( $e->{'reason'}, $s, 'i' );
                $e->{'status'} = $r if length $r;
            }

            $e->{'status'} ||= $softbounce ? '4.0.0' : '5.0.0';
            last;
        }

        $e->{'spec'} = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'command'} ||= 'CONN';
    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Verizon - bounce mail parser class for Verizon.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Verizon;

=head1 DESCRIPTION

Sisimai::MSP::US::Verizon parses a bounce email which created by Verizon.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::US::Verizon->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::Verizon->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::Verizon->smtpagent;

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
