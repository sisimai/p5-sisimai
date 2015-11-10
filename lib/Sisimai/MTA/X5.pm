package Sisimai::MTA::X5;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'from' => qr/\bTWFpbCBEZWxpdmVyeSBTdWJzeXN0ZW0\b/,
    'to'   => qr/\bNotificationRecipients\b/,
};
my $Re1 = {
    'begin'    => qr|\AContent-Type: message/delivery-status|,
    'rfc822'   => qr|\AContent-Type: message/rfc822|,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

sub description { 'Unknown MTA #5' }
sub smtpagent   { 'X5' }

sub scan {
    # Detect an error from Unknown MTA #5
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
    # @since v4.13.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # To: "NotificationRecipients" <...>
    $match++ if defined $mhead->{'to'} && $mhead->{'to'} =~ $Re0->{'to'};

    require Sisimai::MIME;
    if( $mhead->{'from'} =~ $Re0->{'from'} ) {
        # From: "=?iso-2022-jp?B?TWFpbCBEZWxpdmVyeSBTdWJzeXN0ZW0=?=" <...>
        #       Mail Delivery Subsystem
        for my $f ( split( ' ', $mhead->{'from'} ) ) {
            # Check each element of From: header
            next unless Sisimai::MIME->is_mimeencoded( \$f );
            $match++ if Sisimai::MIME->mimedecode( [ $f ] ) =~ m/Mail Delivery Subsystem/;
            last;
        }
    }

    if( Sisimai::MIME->is_mimeencoded( \$mhead->{'subject'} ) ) {
        # Subject: =?iso-2022-jp?B?UmV0dXJuZWQgbWFpbDogVXNlciB1bmtub3du?=
        my $s = Sisimai::MIME->mimedecode( [ $mhead->{'subject'} ] );
        $match++ if $s =~ m/Mail Delivery Subsystem/;
    }

    return undef if $match < 2;

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

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

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
            next unless length $e;
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                # Final-Recipient: RFC822; kijitora@example.jp
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( $e =~ m/\A[Xx]-[Aa]ctual-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ||
                     $e =~ m/\A[Oo]riginal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                # Original-Recipient: rfc822;kijitora@example.co.jp
                $v->{'alias'} = $1;

            } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                # Action: failed
                $v->{'action'} = lc $1;

            } elsif( $e =~ m/\A[Ss]tatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                # Status: 5.1.1
                $v->{'status'} = $1;

            } elsif( $e =~ m/\A[Rr]eporting-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                # Reporting-MTA: dns; mx.example.jp
                $v->{'lhost'} = lc $1;

            } elsif( $e =~ m/\A[Rr]emote-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                # Remote-MTA: DNS; mx.example.jp
                $v->{'rhost'} = lc $1;

            } elsif( $e =~ m/\A[Ll]ast-[Aa]ttempt-[Dd]ate:[ ]*(.+)\z/ ) {
                # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                $v->{'date'} = $1;

            } else {
                # Get an error message from Diagnostic-Code: field
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

        } else {
            # After "message/rfc822"
            next unless $recipients;
            next unless $readcursor & $indicators->{'deliverystatus'};

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
        }

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

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::X5 - bounce mail parser class for unknown MTA #5.

=head1 SYNOPSIS

    use Sisimai::MTA::X5;

=head1 DESCRIPTION

Sisimai::MTA::X5 parses a bounce email which created by Unknown MTA #5. Methods
in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::X5->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::X5->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

