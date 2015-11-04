package Sisimai::MTA::X3;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'from'     => qr/\AMail Delivery System/,
    'begin'    => qr/\A\s+This is an automatically generated Delivery Status Notification/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'rfc822'   => qr|\AContent-Type: message/rfc822|,
    'subject'  => qr/\ADelivery status notification/,
};

sub description { 'Unknown MTA #3' }
sub smtpagent   { 'X3' }

sub scan {
    # Detect an error from Unknown MTA #3
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
    # @since v4.1.9
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'from'}    =~ $RxMTA->{'from'};
    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $indicators = __PACKAGE__->INDICATORS;

    my $datestring = '';
    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor = $indicators->{'deliverystatus'} if $e =~ $RxMTA->{'begin'};
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor = $indicators->{'message-rfc822'} if $e =~ $RxMTA->{'rfc822'};
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

            # ============================================================================
            #      This is an automatically generated Delivery Status Notification.      
            #
            # Delivery to the following recipients failed permanently:
            #
            #   * kijitora@example.com
            #
            #
            # ============================================================================
            #                             Technical details:                             
            #
            # SMTP:RCPT host 192.0.2.8: 553 5.3.0 <kijitora@example.com>... No such user here
            #
            #
            # ============================================================================
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A\s+[*]\s([^ ]+[@][^ ]+)\z/ ) {
                #   * kijitora@example.com
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } else {
                # Detect error message
                if( $e =~ m/\ASMTP:([^ ]+)\s(.+)\z/ ) {
                    # SMTP:RCPT host 192.0.2.8: 553 5.3.0 <kijitora@example.com>... No such user here
                    $v->{'command'} = uc $1;
                    $v->{'diagnosis'} = $2;

                } elsif( $e =~ m/\ARouting: (.+)/ ) {
                    # Routing: Could not find a gateway for kijitora@example.co.jp
                    $v->{'diagnosis'} = $1;
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
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );
        $e->{'status'}    = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}      = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'}    = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'date'}      = $datestring || '';

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::X3 - bounce mail parser class for C<X3>.

=head1 SYNOPSIS

    use Sisimai::MTA::X3;

=head1 DESCRIPTION

Sisimai::MTA::X3 parses a bounce email which created by Unknown MTA #3. Methods
in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::X3->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::X3->smtpagent;

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
