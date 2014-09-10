package Sisimai::MTA::OpenSMTPD;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# http://www.openbsd.org/cgi-bin/man.cgi?query=smtpd&sektion=8
# opensmtpd-5.4.2p1/smtpd/
#   bounce.c/317:#define NOTICE_INTRO \
#   bounce.c/318:    "    Hi!\n\n"    \
#   bounce.c/319:    "    This is the MAILER-DAEMON, please DO NOT REPLY to this e-mail.\n"
#   bounce.c/320:
#   bounce.c/321:const char *notice_error =
#   bounce.c/322:    "    An error has occurred while attempting to deliver a message for\n"
#   bounce.c/323:    "    the following list of recipients:\n\n";
#   bounce.c/324:
#   bounce.c/325:const char *notice_warning =
#   bounce.c/326:    "    A message is delayed for more than %s for the following\n"
#   bounce.c/327:    "    list of recipients:\n\n";
#   bounce.c/328:
#   bounce.c/329:const char *notice_warning2 =
#   bounce.c/330:    "    Please note that this is only a temporary failure report.\n"
#   bounce.c/331:    "    The message is kept in the queue for up to %s.\n"
#   bounce.c/332:    "    You DO NOT NEED to re-send the message to these recipients.\n\n";
#   bounce.c/333:
#   bounce.c/334:const char *notice_success =
#   bounce.c/335:    "    Your message was successfully delivered to these recipients.\n\n";
#   bounce.c/336:
#   bounce.c/337:const char *notice_relay =
#   bounce.c/338:    "    Your message was relayed to these recipients.\n\n";
#   bounce.c/339:
my $RxMTA = {
    'from'     => qr/\AMailer Daemon [<]MAILER-DAEMON[@]/,
    'begin'    => qr/\A\s*This is the MAILER-DAEMON, please DO NOT REPLY to this e-mail[.]\z/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'rfc822'   => qr/\A\s*Below is a copy of the original message:\z/,
    'subject'  => qr/\ADelivery status notification/,
    'received' => qr/[ ][(]OpenSMTPD[)][ ]with[ ]/,
};

my $RxErr = {
    'expired' => [
        # smtpd/queue.c:221|  envelope_set_errormsg(&evp, "Envelope expired");
        qr/Envelope expired/,
    ],
    'hostunknown' => [
        # smtpd/mta.c:976|  relay->failstr = "Invalid domain name";
        qr/Invalid domain name/,

        # smtpd/mta.c:980|  relay->failstr = "Domain does not exist";
        qr/Domain does not exist/,
    ],
    'notaccept' => [
        # smtp/mta.c:1085|  relay->failstr = "Destination seem to reject all mails";
        qr/Destination seem to reject all mails/,
    ],
    'systemerror' => [
        #  smtpd/mta.c:972|  relay->failstr = "Temporary failure in MX lookup";
        qr/Temporary failure in MX lookup/,
        qr/No MX found for domain/,
        qr/bad DNS lookup error code/,
        qr/Could not retrieve source address/,
        qr/No valid route to remote MX/,
        qr/Network error on destination MXs/,
        qr/No MX found for destination/,
        qr/Address family mismatch on destination MXs/,
        qr/All routes to destination blocked/,
        qr/No valid route to destination/,
        qr/Loop detected/,
    ],
    'securityerror' => [
        # smtpd/mta.c:1013|  relay->failstr = "Could not retrieve credentials";
        qr/Could not retrieve credentials/,
    ],
};

sub version     { '4.0.2' }
sub description { 'OpenSMTPD' }
sub smtpagent   { 'OpenSMTPD' }

sub scan {
    # @Description  Detect an error from OpenSMTPD
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};
    return undef unless $mhead->{'from'}    =~ $RxMTA->{'from'};
    return undef unless grep { $_ =~ $RxMTA->{'received'} } @{ $mhead->{'received'} };

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $softbounce = 0;     # (Integer) 1 = Soft bounce

    my $v = undef;
    my $p = undef;
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
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
            next unless length $e;

            #    Hi!
            #
            #    This is the MAILER-DAEMON, please DO NOT REPLY to this e-mail.
            #
            #    An error has occurred while attempting to deliver a message for
            #    the following list of recipients:
            #
            # kijitora@example.jp: 550 5.2.2 <kijitora@example>... Mailbox Full
            #
            #    Below is a copy of the original message:
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A([^ ]+?[@][^ ]+?):?[ ](.+)\z/ ) {
                # kijitora@example.jp: 550 5.2.2 <kijitora@example>... Mailbox Full
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $2;
                $recipients++;
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = undef;
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'date'}    ||= $mhead->{'date'};
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

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

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::OpenSMTPD - bounce mail parser class for v8 OpenSMTPD.

=head1 SYNOPSIS

    use Sisimai::MTA::OpenSMTPD;

=head1 DESCRIPTION

Sisimai::MTA::OpenSMTPD parses a bounce email which created by v8 OpenSMTPD.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::OpenSMTPD->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::OpenSMTPD->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::OpenSMTPD->smtpagent;

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
