package Sisimai::MTA::McAfee;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'x-nai'   => qr/Modified by McAfee /,
    'subject' => qr/\ADelivery Status\z/,
};
my $Re1 = {
    'begin'   => qr/[-]+ The following addresses had delivery problems [-]+\z/,
    'error'   => qr|\AContent-Type: [^ ]+/[^ ]+; name="deliveryproblems[.]txt"|,
    'rfc822'  => qr|\AContent-Type: message/rfc822\z|,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $ReFailure = {
    'userunknown' => qr{(?:
         User[ ][(].+[@].+[)][ ]unknown[.]
        |550[ ]Unknown[ ]user[ ][^ ]+[@][^ ]+
        )
    }x,
};

sub description { 'McAfee Email Appliance' }
sub smtpagent   { 'McAfee' }
sub headerlist  { return [ 'X-NAI-Header' ] }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from McAfee
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
    # @since v4.1.1
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'x-nai-header'};
    return undef unless $mhead->{'x-nai-header'} =~ $Re0->{'x-nai'};
    return undef unless $mhead->{'subject'}      =~ $Re0->{'subject'};

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
    my $diagnostic = '';    # (String) Alternative diagnostic message

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::Address;

    for my $e ( @stripedtxt ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $Re1->{'begin'} ) {
                $readcursor |= $indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $Re1->{'rfc822'} ) {
                $readcursor |= $indicators->{'message-rfc822'};
                next;
            }
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

            # Content-Type: text/plain; name="deliveryproblems.txt"
            #
            #    --- The following addresses had delivery problems ---
            #
            # <user@example.com>   (User unknown user@example.com)
            #
            # --------------Boundary-00=_00000000000000000000
            # Content-Type: message/delivery-status; name="deliverystatus.txt"
            #
            $v = $dscontents->[ -1 ];

            if( $e =~ m{\A[<]([^ ]+[@][^ ]+)[>][\s\t]+[(](.+)[)]\z} ) {
                # <kijitora@example.co.jp>   (Unknown user kijitora@example.co.jp)
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $diagnostic = $2;
                $recipients++;

            } elsif( $e =~ m/\A[Oo]riginal-[Rr]ecipient:[ ]*([^ ]+)\z/ ) {
                # Original-Recipient: <kijitora@example.co.jp>
                $v->{'alias'} = Sisimai::Address->s3s4( $1 );

            } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                # Action: failed
                $v->{'action'} = lc $1;

            } elsif( $e =~ m/\A[Rr]emote-MTA:[ ]*(.+)\z/ ) {
                # Remote-MTA: 192.0.2.192
                $v->{'rhost'} = lc $1;

            } else {

                if( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                    # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                    $v->{'spec'} = uc $1;
                    $v->{'diagnosis'} = $2;

                } elsif( $p =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*/ && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                    # Continued line of the value of Diagnostic-Code header
                    $v->{'diagnosis'} .= ' '.$1;
                    $e = 'Diagnostic-Code: '.$e;
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
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} || $diagnostic );

        SESSION: for my $r ( keys %$ReFailure ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
            $e->{'reason'} = $r;
            last;
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::McAfee - bounce mail parser class for C<McAfee Email Appliance>.

=head1 SYNOPSIS

    use Sisimai::MTA::McAfee;

=head1 DESCRIPTION

Sisimai::MTA::McAfee parses a bounce email which created by C<McAfee Email
Appliance>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::McAfee->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::McAfee->smtpagent;

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

