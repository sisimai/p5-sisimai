package Sisimai::MSP::JP::KDDI;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'       => qr/no-reply[@].+[.]dion[.]ne[.]jp/,
    'reply-to'   => qr/\Afrom\s+\w+[.]auone[-]net[.]jp\s/,
    'received'   => qr/\Afrom[ ](?:.+[.])?ezweb[.]ne[.]jp[ ]/,
    'message-id' => qr/[@].+[.]ezweb[.]ne[.]jp[>]\z/,
    'begin'      => [
        qr/\AYour mail sent on:? [A-Z][a-z]{2}[,]/,
        qr/\AYour mail attempted to be delivered on:? [A-Z][a-z]{2}[,]/,
    ],
    'rfc822'     => qr|\AContent-Type: message/rfc822\z|,
    'error'      => qr/Could not be delivered to:? /,
    'endof'      => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $RxErr = {
    'mailboxfull' => [
        qr/As their mailbox is full/,
    ],
    'norelaying' => [
        qr/Due to the following SMTP relay error/,
    ],
    'hostunknown' => [
        qr/As the remote domain doesnt exist/,
    ],
};

sub version     { '4.0.7' }
sub description { 'au by KDDI' }
sub smtpagent   { 'JP::KDDI' }

sub scan {
    # @Description  Detect an error from KDDI
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match++ if $mhead->{'from'} =~ $RxMSP->{'from'};
    $match++ if $mhead->{'reply-to'} && $mhead->{'reply-to'} =~ $RxMSP->{'reply-to'};
    $match++ if $mhead->{'received'} =~ $RxMSP->{'received'};
    return undef unless $match;

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

    require Sisimai::String;
    require Sisimai::RFC5322;
    require Sisimai::Address;

    for my $e ( @$stripedtxt ) {

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
            next unless ( grep { $e =~ $_ } @{ $RxMSP->{'begin'} } ) .. ( $e =~ $RxMSP->{'rfc822'} );
            next unless length $e;

            $v = $dscontents->[ -1 ];
            if( $e =~ m/\A\s+Could not be delivered to: [<]([^ ]+[@][^ ]+)[>]/ ) {
                # Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
                #     Could not be delivered to: <******@**.***.**>
                #     As their mailbox is full.
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }

                my $r = Sisimai::Address->s3s4( $1 );
                if( Sisimai::RFC5322->is_emailaddress( $r ) ) {
                    $v->{'recipient'} = $r;
                    $recipients++;
                }

            } elsif( $e =~ m/Your mail sent on: (.+)\z/ ) {
                # Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
                $v->{'date'} = $1;

            } else {
                #     As their mailbox is full.
                $v->{'diagnosis'} .= $e.' ' if $e =~ m/\A\s+/;
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    return undef unless $recipients;
    require Sisimai::RFC3463;

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

        if( exists $mhead->{'x-spasign'} && $mhead->{'x-spasign'} eq 'NG' ) {
            # Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
            # Filtered recipient returns message that include 'X-SPASIGN' header
            $e->{'reason'} = 'filtered';

        } else {
            if( $e->{'command'} eq 'RCPT' ) {
                # set "userunknown" when the remote server rejected after RCPT
                # command.
                $e->{'reason'} = 'userunknown';

            } else {
                # SMTP command is not RCPT
                SESSION: for my $r ( keys %$RxErr ) {
                    # Verify each regular expression of session errors
                    PATTERN: for my $rr ( @{ $RxErr->{ $r } } ) {
                        # Check each regular expression
                        next(PATTERN) unless $e->{'diagnosis'} =~ $rr;
                        $e->{'reason'} = $r;
                        last(SESSION);
                    }
                }
            }
        }

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

Sisimai::MSP::JP::KDDI - bounce mail parser class for KDDI.

=head1 SYNOPSIS

    use Sisimai::MSP::JP::KDDI;

=head1 DESCRIPTION

Sisimai::MSP::JP::KDDI parses a bounce email which created by KDDI.  Methods in
the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::JP::KDDI->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::JP::KDDI->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::JP::KDDI->smtpagent;

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
