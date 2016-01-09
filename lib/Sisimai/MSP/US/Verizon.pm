package Sisimai::MSP::US::Verizon;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'received' => qr/by .+[.]vtext[.]com /,
    'vtext.com' => {
        'from' => qr/\Apost_master[@]vtext[.]com\z/,
    },
    'vzwpix.com' => {
        'from'    => qr/[<]?sysadmin[@].+[.]vzwpix[.]com[>]?\z/,
        'subject' => qr/Undeliverable Message/,
    },
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'Verizon Wireless: http://www.verizonwireless.com' }
sub smtpagent   { 'US::Verizon' }
sub pattern     { 
    return {
        'from' => qr/[<]?(?:\Apost_master[@]vtext|sysadmin[@].+[.]vzwpix)[.]com[>]?\z/,
        'subject' => $Re0->{'vzwpix.com'}->{'subject'},
    };
}

sub scan {
    # Detect an error from Verizon
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
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $vtext = undef;

    while(1) {
        # Check the value of "From" header
        last unless grep { $_ =~ $Re0->{'received'} } @{ $mhead->{'received'} };
        $vtext = 1 if $mhead->{'from'} =~ $Re0->{'vtext.com'}->{'from'};
        $vtext = 0 if $mhead->{'from'} =~ $Re0->{'vzwpix.com'}->{'from'};
        last;
    }
    return undef unless defined $vtext;

    require Sisimai::MIME;
    require Sisimai::Address;
    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $senderaddr = '';    # (String) Sender address in the message body
    my $subjecttxt = '';    # (String) Subject of the original message

    my $Re1        = {};    # (Ref->Hash) Delimiter patterns
    my $ReFailure  = {};    # (Ref->Hash) Error message patterns
    my $boundary00 = '';    # (String) Boundary string
    my $v = undef;

    if( $vtext == 1 ) {
        # vtext.com
        $Re1 = {
            'begin'  => qr/\AError:[ \t]/,
            'rfc822' => qr/\A__BOUNDARY_STRING_HERE__\z/,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $ReFailure = {
            'userunknown' => qr{
                # The attempted recipient address does not exist.
                550[ ][-][ ]Requested[ ]action[ ]not[ ]taken:[ ]no[ ]such[ ]user[ ]here
            }x,
        };

        $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
        $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
        $Re1->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;

        for my $e ( @hasdivided ) {
            # Read each line between $Re0->{'begin'} and $Re0->{'rfc822'}.
            unless( $readcursor ) {
                # Beginning of the bounce message or delivery status part
                if( $e =~ $Re1->{'begin'} ) {
                    $readcursor |= $Indicators->{'deliverystatus'};
                    next;
                }
            }

            unless( $readcursor & $Indicators->{'message-rfc822'} ) {
                # Beginning of the original message part
                if( $e =~ $Re1->{'rfc822'} ) {
                    $readcursor |= $Indicators->{'message-rfc822'};
                    next;
                }
            }

            if( $readcursor & $Indicators->{'message-rfc822'} ) {
                # After "message/rfc822"
                if( $e =~ m/\A[ ][ ]([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                    # Get required headers only
                    my $lhs = lc $1;
                    $previousfn = '';
                    next unless exists $RFC822Head->{ $lhs };

                    $previousfn  = $lhs;
                    $rfc822part .= $e."\n";

                } elsif( $e =~ m/\A[ \t]+/ ) {
                    # Continued line from the previous line
                    next if $rfc822next->{ $previousfn };
                    $rfc822part .= $e."\n" if exists $LongFields->{ $previousfn };

                } else {
                    # Check the end of headers in rfc822 part
                    next unless exists $LongFields->{ $previousfn };
                    next if length $e;
                    $rfc822next->{ $previousfn } = 1;
                }
            } else {
                # Before "message/rfc822"
                next unless $readcursor & $Indicators->{'deliverystatus'};
                next unless length $e;

                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A[ \t]+RCPT TO: (.*)\z/ ) {
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

                } elsif( $e =~ m/\A[ \t]+MAIL FROM:[ \t](.+)\z/ ) {
                    #   MAIL FROM: *******@hg.example.com
                    $senderaddr ||= $1;

                } elsif( $e =~ m/\A[ \t]+Subject:[ \t](.+)\z/ ) {
                    #   Subject:
                    $subjecttxt ||= $1;

                } else {

                    if( $e =~ m/\A(\d{3})[ \t][-][ \t](.*)\z/ ) {
                        # 550 - Requested action not taken: no such user here
                        $v->{'diagnosis'} = $e;
                    }
                }
            } # End of if: rfc822
        }
    } else {
        # vzwpix.com
        $Re1 = {
            'begin'  => qr/\AMessage could not be delivered to mobile/,
            'rfc822' => qr/\A__BOUNDARY_STRING_HERE__\z/,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $ReFailure = {
            'userunknown' => qr{
                No[ ]valid[ ]recipients[ ]for[ ]this[ ]MM
            }x,
        };

        $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
        $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
        $Re1->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;

        for my $e ( @hasdivided ) {
            # Read each line between $Re0->{'begin'} and $Re0->{'rfc822'}.
            unless( $readcursor ) {
                # Beginning of the bounce message or delivery status part
                if( $e =~ $Re1->{'begin'} ) {
                    $readcursor |= $Indicators->{'deliverystatus'};
                    next;
                }
            }

            unless( $readcursor & $Indicators->{'message-rfc822'} ) {
                # Beginning of the original message part
                if( $e =~ $Re1->{'rfc822'} ) {
                    $readcursor |= $Indicators->{'message-rfc822'};
                    next;
                }
            }

            if( $readcursor & $Indicators->{'message-rfc822'} ) {
                # After "message/rfc822"
                if( $e =~ m/\A[ ][ ]([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                    # Get required headers only
                    my $lhs = lc $1;
                    $previousfn = '';
                    next unless exists $RFC822Head->{ $lhs };

                    $previousfn  = $lhs;
                    $rfc822part .= $e."\n";

                } elsif( $e =~ m/\A[ \t]+/ ) {
                    # Continued line from the previous line
                    next if $rfc822next->{ $previousfn };
                    $rfc822part .= $e."\n" if exists $LongFields->{ $previousfn };

                } else {
                    # Check the end of headers in rfc822 part
                    next unless exists $LongFields->{ $previousfn };
                    next if length $e;
                    $rfc822next->{ $previousfn } = 1;
                }
            } else {
                # Before "message/rfc822"
                next unless $readcursor & $Indicators->{'deliverystatus'};
                next unless length $e;

                $v = $dscontents->[ -1 ];

                if( $e =~ m/\ATo:[ \t]+(.*)\z/ ) {
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

                } elsif( $e =~ m/\AFrom:[ \t](.+)\z/ ) {
                    # From: kijitora <kijitora@example.jp>
                    $senderaddr ||= Sisimai::Address->s3s4( $1 );

                } elsif( $e =~ m/\ASubject:[ \t](.+)\z/ ) {
                    #   Subject:
                    $subjecttxt ||= $1;

                } else {

                    if( $e =~ m/\AError:[ \t]+(.+)\z/ ) {
                        # Message could not be delivered to mobile.
                        # Error: No valid recipients for this MM
                        $v->{'diagnosis'} = $e;
                    }
                }
            } # End of if: rfc822
        }
    }
    return undef unless $recipients;

    # Set the value of "MAIL FROM:" or "From:", and "Subject"
    $rfc822part .= sprintf( "From: %s\n", $senderaddr ) unless $rfc822part =~ m/\bFrom: /;
    $rfc822part .= sprintf( "Subject: %s\n", $subjecttxt ) unless $rfc822part =~ m/\bSubject: /;

    require Sisimai::String;
    require Sisimai::SMTP::Status;

    for my $e ( @$dscontents ) {
        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r0 = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r0->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r0->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        SESSION: for my $r ( keys %$ReFailure ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
            $e->{'reason'} = $r;
            last;
        }

        $e->{'status'} = Sisimai::SMTP::Status->find( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'agent'}  = __PACKAGE__->smtpagent;
    }

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Verizon - bounce mail parser class for C<Verizon Wireless>.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Verizon;

=head1 DESCRIPTION

Sisimai::MSP::US::Verizon parses a bounce email which created by C<Verizon
Wireless>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

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

Copyright (C) 2014-2016 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
