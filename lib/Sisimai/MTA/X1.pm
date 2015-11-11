package Sisimai::MTA::X1;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'from'     => qr/["]Mail Deliver System["] /,
    'subject'  => qr/\AReturned Mail: /,
};
my $Re1 = {
    'begin'    => qr/\AThe original message was received at (.+)\z/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'rfc822'   => qr/\AReceived: from \d+[.]\d+[.]\d+[.]\d/,
};

sub description { 'Unknown MTA #1' }
sub smtpagent   { 'X1' }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from Unknown MTA #1
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

    return undef unless $mhead->{'subject'} =~ $Re0->{'subject'};
    return undef unless $mhead->{'from'}    =~ $Re0->{'from'};
    require Sisimai::RFC5322;

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @stripedtxt = split( "\n", $$mbody );
    my $indicators = __PACKAGE__->INDICATORS;
    my $longfields = Sisimai::RFC5322->LONGFIELDS;
    my $rfc822head = Sisimai::RFC5322->HEADERFIELDS;
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $datestring = '';

    my $v = undef;
    my $p = '';

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
                next unless exists $rfc822head->{ $whs };

                $previousfn  = lc $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ $previousfn };
                $rfc822part .= $e."\n" if exists $longfields->{ $previousfn };

            } else {
                # Check the end of headers in rfc822 part
                next unless exists $longfields->{ $previousfn };
                next if length $e;
                $rfc822next->{ $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless $readcursor & $indicators->{'deliverystatus'};
            next unless length $e;

            # The original message was received at Thu, 29 Apr 2010 23:34:45 +0900 (JST) 
            # from shironeko@example.jp
            #
            # ---The following addresses had delivery errors---
            #
            # kijitora@example.co.jp [User unknown]
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A([^ ]+?[@][^ ]+?)\s+\[(.+)\]\z/ ) {
                # kijitora@example.co.jp [User unknown]
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $2;
                $recipients++;

            } elsif( $e =~ $Re1->{'begin'} ) {
                # The original message was received at Thu, 29 Apr 2010 23:34:45 +0900 (JST) 
                $datestring = $1;
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

Sisimai::MTA::X1 - bounce mail parser class for C<X1>.

=head1 SYNOPSIS

    use Sisimai::MTA::X1;

=head1 DESCRIPTION

Sisimai::MTA::X1 parses a bounce email which created by Unknown MTA #1.  Methods
in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::X1->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::X1->smtpagent;

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

