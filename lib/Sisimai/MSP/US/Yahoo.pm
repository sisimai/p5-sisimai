package Sisimai::MSP::US::Yahoo;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'    => qr//,
    'begin'   => qr/\ASorry, we were unable to deliver your message/,
    'rfc822'  => qr/\A--- Below this line is a copy of the message[.]\z/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\AFailure Notice\z/,
};

sub version     { '4.0.2' }
sub description { 'Yahoo! MAIL' }
sub smtpagent   { 'US::Yahoo' }
sub headerlist  { 
    return [ 'X-Originating-IP', 'X-YahooFilteredBulk', 'X-YMailISG' ]
}

sub scan {
    # @Description  Detect an error from Yahoo! MAIL
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'x-originating-ip'};
    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

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

            } elsif( $e =~ m/\ARemote host said:/ ) {
                # Remote host said: 550 5.1.1 <kijitora@example.org>... User Unknown [RCPT_TO]
                $v->{'diagnosis'} = $e;

                if( $e =~ m/\[([A-Z]{4}).*\]\z/ ) {
                    # Get SMTP command from the value of "Remote host said:"
                    $v->{'command'} = $1;
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

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'diagnosis'} =~ s{\\n}{ }g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        $e->{'status'}  =  Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}  ||= 'SMTP';
        $e->{'agent'} ||= __PACKAGE__->smtpagent;
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

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::US::Yahoo->version;

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

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

