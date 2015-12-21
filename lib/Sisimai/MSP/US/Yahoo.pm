package Sisimai::MSP::US::Yahoo;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'subject' => qr/\AFailure Notice\z/,
};
my $Re1 = {
    'begin'   => qr/\ASorry, we were unable to deliver your message/,
    'rfc822'  => qr/\A--- Below this line is a copy of the message[.]\z/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'Yahoo! MAIL: https://www.yahoo.com' }
sub smtpagent   { 'US::Yahoo' }

# X-YMailISG: YtyUVyYWLDsbDh...
# X-YMail-JAS: Pb65aU4VM1mei...
# X-YMail-OSG: bTIbpDEVM1lHz...
# X-Originating-IP: [192.0.2.9]
sub headerlist  { return [ 'X-YMailISG' ] }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from Yahoo! MAIL
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
    # @since v4.1.3
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'x-ymailisg'};
    if( 0 ) {
        return undef unless $mhead->{'subject'} =~ $Re0->{'subject'};
    }

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;

    for my $e ( @hasdivided ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
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
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = lc $1;
                $previousfn = '';
                next unless exists $RFC822Head->{ $lhs };

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A\s+/ ) {
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

            # Sorry, we were unable to deliver your message to the following address.
            #
            # <kijitora@example.org>:
            # Remote host said: 550 5.1.1 <kijitora@example.org>... User Unknown [RCPT_TO]
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A[<](.+[@].+)[>]:\s*\z/ ) {
                # <kijitora@example.org>:
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } else {
                if( $e =~ m/\ARemote host said:/ ) {
                    # Remote host said: 550 5.1.1 <kijitora@example.org>... User Unknown [RCPT_TO]
                    $v->{'diagnosis'} = $e;

                    if( $e =~ m/\[([A-Z]{4}).*\]\z/ ) {
                        # Get SMTP command from the value of "Remote host said:"
                        $v->{'command'} = $1;
                    }
                } else {
                    # <mailboxfull@example.jp>:
                    # Remote host said:
                    # 550 5.2.2 <mailboxfull@example.jp>... Mailbox Full
                    # [RCPT_TO]
                    if( $v->{'diagnosis'} =~ m/\ARemote host said:\z/ ) {
                        # Remote host said:
                        # 550 5.2.2 <mailboxfull@example.jp>... Mailbox Full
                        if( $e =~ m/\[([A-Z]{4}).*\]\z/ ) {
                            # [RCPT_TO]
                            $v->{'command'} = $1;

                        } else {
                            # 550 5.2.2 <mailboxfull@example.jp>... Mailbox Full
                            $v->{'diagnosis'} = $e;
                        }
                    }
                }
            }
        } # End of if: rfc822
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::SMTP::Status;

    for my $e ( @$dscontents ) {
        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} =~ s{\\n}{ }g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        $e->{'status'} =  Sisimai::SMTP::Status->find( $e->{'diagnosis'} );
        $e->{'spec'} ||= 'SMTP';
        $e->{'agent'}  = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Yahoo - bounce mail parser class for C<Yahoo! MAIL>.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Yahoo;

=head1 DESCRIPTION

Sisimai::MSP::US::Yahoo parses a bounce email which created by C<Yahoo! MAIL>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::Yahoo->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::Yahoo->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

