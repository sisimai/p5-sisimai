package Sisimai::MTA::MailFoundry;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'begin'    => qr/\AThis is a MIME encoded message\z/,
    'error'    => qr/\ADelivery failed for the following reason:\z/,
    'rfc822'   => qr|\AContent-Type: message/rfc822\z|,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'received' => qr/[(]MAILFOUNDRY[)] id /,
    'subject'  => qr/\AMessage delivery has failed\z/,
};

sub version     { '4.0.1' }
sub description { 'MailFoundry' }
sub smtpagent   { 'MailFoundry' }

sub scan {
    # @Description  Detect an error from MailFoundry
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};
    return undef unless grep { $_ =~ $RxMTA->{'received'} } @{ $mhead->{'received'} };

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
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
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
            next unless length $e;

            # Unable to deliver message to: <kijitora@example.org>
            # Delivery failed for the following reason:
            # Server mx22.example.org[192.0.2.222] failed with: 550 <kijitora@example.org> No such user here
            #
            # This has been a permanent failure.  No further delivery attempts will be made.
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\AUnable to deliver message to: [<]([^ ]+[@][^ ]+)[>]\z/ ) {
                # Unable to deliver message to: <kijitora@example.org>
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } else {
                # Error message
                if( $e =~ $RxMTA->{'error'} ) {
                    # Delivery failed for the following reason:
                    $v->{'diagnosis'} = $e;

                } else {
                    # Detect error message
                    next unless length $e;
                    next unless length $v->{'diagnosis'};
                    next if $e =~ m/\A[-]+/;

                    if( $e =~ m/\AThis has been a permanent failure/ ) {
                        # This has been a permanent failure.  No further delivery attempts will be made.
                        $v->{'softbounce'} = 0;

                    } else {
                        # Server mx22.example.org[192.0.2.222] failed with: 550 <kijitora@example.org> No such user here
                        $v->{'diagnosis'} .= ' '.$e;
                    }
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
        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::MailFoundry - bounce mail parser class for MailFoundry.

=head1 SYNOPSIS

    use Sisimai::MTA::MailFoundry;

=head1 DESCRIPTION

Sisimai::MTA::MailFoundry parses a bounce email which created by MailFoundry.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::MailFoundry->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::MailFoundry->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::MailFoundry->smtpagent;

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

