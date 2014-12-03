package Sisimai::MSP::DE::GMX;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'    => qr/\AMAILER-DAEMON[@]/,
    'begin'   => qr/\AThis message was created automatically by mail delivery software/,
    'rfc822'  => qr/\A--- The header of the original message is following/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\AMail delivery failed: returning message to sender\z/,
};

my $RxSess = {
    'expired' => [
        qr/delivery retry timeout exceeded/,
    ],
};

sub version     { '4.0.1' }
sub description { 'GMX' }
sub smtpagent   { 'DE::GMX' }
sub headerlist  { 
    return [ 'Envelope-To', 'X-GMX-Antispam', 'X-GMX-Antivirus' ]
}

sub scan {
    # @Description  Detect an error from GMX
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'envelope-to'};
    return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};
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

            # This message was created automatically by mail delivery software.
            #
            # A message that you sent could not be delivered to one or more of
            # its recipients. This is a permanent error. The following address
            # failed:
            #
            # "shironeko@example.jp":
            # SMTP error from remote server after RCPT command:
            # host: mx.example.jp
            # 5.1.1 <shironeko@example.jp>... User Unknown
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A["]([^ ]+[@][^ ]+)["]:\z/ ||
                $e =~ m/\A[<]([^ ]+[@][^ ]+)[>]\z/ ) {
                # "shironeko@example.jp":
                # ---- OR ----
                # <kijitora@6jo.example.co.jp>
                #
                # Reason:
                # delivery retry timeout exceeded
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( $e =~ m/\ASMTP error .+ ([A-Z]{4}) command:\z/ ) {
                # SMTP error from remote server after RCPT command:
                $v->{'command'} = $1;

            } elsif( $e =~ m/\Ahost:\s*(.+)\z/ ) {
                # host: mx.example.jp
                $v->{'rhost'} = $1;

            } else {
                # Get error message
                if( $e =~ m/\b[45][.]\d[.]\d\b/  ||
                    $e =~ m/[<][^ ]+[@][^ ]+[>]/ ||
                    $e =~ m/\b[45]\d{2}\b/ ) {

                    $v->{'diagnosis'} ||= $e;

                } else {
                    next if $e =~ m/\A\z/;
                    if( $e =~ m/\AReason:\z/ ) {
                        # Reason:
                        # delivery retry timeout exceeded
                        $v->{'diagnosis'} = $e;

                    } elsif( $v->{'diagnosis'} =~ m/\AReason:\z/ ) {
                        $v->{'diagnosis'} = $e;
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

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'diagnosis'} =~ s{\\n}{ }g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        SESSION: for my $r ( keys %$RxSess ) {
            # Verify each regular expression of session errors
            PATTERN: for my $rr ( @{ $RxSess->{ $r } } ) {
                # Check each regular expression
                next unless $e->{'diagnosis'} =~ $rr;
                $e->{'reason'} = $r;
                last(SESSION);
            }
        }

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

Sisimai::MSP::DE::GMX - bounce mail parser class for C<GMX>.

=head1 SYNOPSIS

    use Sisimai::MSP::DE::GMX;

=head1 DESCRIPTION

Sisimai::MSP::DE::GMX parses a bounce email which created by C<GMX>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::DE::GMX->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::DE::GMX->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::DE::GMX->smtpagent;

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

