package Sisimai::MTA::Domino;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'begin'     => qr/\AYour message/,
    'rfc822'    => qr|\AContent-Type: message/delivery-status\z|,
    'endof'     => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'   => qr/\ADELIVERY FAILURE:/,
};

my $RxErr = {
    'userunknown' => [
        qr/not listed in Domino Directory/,
        qr/not listed in public Name & Address Book/,
        qr/Domino ディレクトリには見つかりません/,
    ],
    'filtered' => [
        qr/Cannot route mail to user/,
    ],
    'systemerror' => [
        qr/Several matches found in Domino Directory/,
    ],
};

sub version     { '4.0.2' }
sub description { 'IBM Domino' }
sub smtpagent   { 'Domino' }

sub scan {
    # @Description  Detect an error from IBM Domino
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $subjecttxt = '';    # (String) The value of Subject:

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::Address;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        next unless length $e;

        if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
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
            next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
            # Your message
            #
            #   Subject: Test Bounce
            #
            # was not delivered to:
            #
            #   kijitora@example.net
            #
            # because:
            #
            #   User some.name (kijitora@example.net) not listed in Domino Directory
            #
            $v = $dscontents->[ -1 ];
            if( $e =~ m/\Awas not delivered to:\z/ ) {
                # was not delivered to:
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} ||= $e;
                $recipients++;

            } elsif( $e =~ m/\A\s\s([^ ]+[@][^ ]+)\z/ ) {
                # Continued from the line "was not delivered to:"
                #   kijitora@example.net
                $v->{'recipient'} = Sisimai::Address->s3s4( $1 );

            } elsif( $e =~ m/\Abecause:\z/ ) {
                # because:
                $v->{'diagnosis'} = $e;

            } else {

                if( exists $v->{'diagnosis'} && $v->{'diagnosis'} eq 'because:' ) {
                    # Error message, continued from the line "because:"
                    $v->{'diagnosis'} = $e;

                } elsif( $e =~ m/\A\s\sSubject: (.+)\z/ ) {
                    #   Subject: Nyaa
                    $subjecttxt = $1;
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
        $e->{'agent'} ||= __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );
        $e->{'recipient'} = Sisimai::Address->s3s4( $e->{'recipient'} );

        for my $r ( keys %$RxErr ) {
            # Check each regular expression of Domino error messages
            next unless grep { $e->{'diagnosis'} =~ $_ } @{ $RxErr->{ $r } };
            $e->{'reason'} = $r;
            my $s = Sisimai::RFC3463->status( $r, 'p', 'i' );
            $e->{'status'} = $s if length $s;
            last;
        }

        $e->{'spec'} = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;

        unless( $rfc822part =~ m/\bSubject:/ ) {
            # Fallback: Add the value of Subject as a Subject header
            $rfc822part .= sprintf( "Subject: %s\n", $subjecttxt );
        }

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Domino - bounce mail parser class for IBM Domino Server.

=head1 SYNOPSIS

    use Sisimai::MTA::Domino;

=head1 DESCRIPTION

Sisimai::MTA::Domino parses a bounce email which created by IBM Domino Server. 
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Domino->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Domino->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Domino->smtpagent;

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
