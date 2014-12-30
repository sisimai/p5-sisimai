package Sisimai::MSP::JP::EZweb;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'       => qr/[<]?(?>postmaster[@]ezweb[.]ne[.]jp)[>]?/i,
    'subject'    => qr/\AMail System Error - Returned Mail\z/,
    'received'   => qr/\Afrom[ ](?:.+[.])?ezweb[.]ne[.]jp[ ]/,
    'message-id' => qr/[@].+[.]ezweb[.]ne[.]jp[>]\z/,
    'begin'      => [
        qr/\AThe user[(]s[)]\s/,
        qr/\AYour message\s/,
        qr/\AEach of the following|The following/,
        qr/\A[<][^ ]+[@][^ ]+[>]\z/,
    ],
    'rfc822'     => [
        qr/\A[-]{50}/,
        qr|\AContent-Type: message/rfc822\z|,
    ],
    'endof'      => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $RxErr = {
    #'notaccept' => [
    #    qr/The following recipients did not receive this message:/,
    #],
    'mailboxfull' => [
        qr/The user[(]s[)] account is temporarily over quota/,
    ],
    'suspend' => [
        # http://www.naruhodo-au.kddi.com/qa3429203.html
        # The recipient may be unpaid user...?
        qr/The user[(]s[)] account is disabled[.]/,
        qr/The user[(]s[)] account is temporarily limited[.]/,
    ],
    'expired' => [
        # Your message was not delivered within 0 days and 1 hours.
        # Remote host is not responding.
        qr/Your message was not delivered within /,
    ],
    'onhold' => [
        qr/Each of the following recipients was rejected by a remote mail server/,
    ],
};

sub version     { '4.0.6' }
sub description { 'au EZweb: http://www.au.kddi.com/mobile/' }
sub smtpagent   { 'JP::EZweb' }
sub headerlist  { return [ 'X-SPASIGN' ] }

sub scan {
    # @Description  Detect an error from EZweb
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # Pre-process email headers of NON-STANDARD bounce message au by EZweb, as
    # known as ezweb.ne.jp.
    #   Subject: Mail System Error - Returned Mail
    #   From: <Postmaster@ezweb.ne.jp>
    #   Received: from ezweb.ne.jp (wmflb12na02.ezweb.ne.jp [222.15.69.197])
    #   Received: from nmomta.auone-net.jp ([aaa.bbb.ccc.ddd]) by ...
    #
    $match++ if $mhead->{'from'}     =~ $RxMSP->{'from'};
    $match++ if $mhead->{'subject'}  =~ $RxMSP->{'subject'};
    $match++ if $mhead->{'received'} =~ $RxMSP->{'received'};
    if( defined $mhead->{'message-id'} ) {
        $match++ if $mhead->{'message-id'} =~ $RxMSP->{'message-id'};
    }
    return undef if $match < 2;

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

    require Sisimai::MIME;
    require Sisimai::String;
    require Sisimai::RFC5322;
    require Sisimai::Address;

    my $rxboundary = Sisimai::MIME->boundary( $mhead->{'content-type'}, 1 );
    my $rxmessages = [];
    push @{ $RxMSP->{'rfc822'} }, qr|\A$rxboundary\z| if length $rxboundary;
    map { push @$rxmessages, @{ $RxErr->{ $_ } } } ( keys %$RxErr );

    for my $e ( @$stripedtxt ) {

        if( ( grep { $e =~ $_ } @{ $RxMSP->{'rfc822'} } ) .. ( $e =~ $RxMSP->{'endof'} ) ) {
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
            next unless
                ( grep { $e =~ $_ } @{ $RxMSP->{'begin'} } ) .. 
                ( grep { $e =~ $_ } @{ $RxMSP->{'rfc822'} } );
            next unless length $e;

            $v = $dscontents->[ -1 ];
            if( $e =~ m/\A[<]([^ ]+[@][^ ]+)[>]\z/ ||
                $e =~ m/\A[<]([^ ]+[@][^ ]+)[>]:?(.*)\z/ ||
                $e =~ m/\A\s+Recipient: [<]([^ ]+[@][^ ]+)[>]/ ) {
                # The user(s) account is disabled.
                #
                # <***@ezweb.ne.jp>: 550 user unknown (in reply to RCPT TO command)
                # 
                #  -- OR --
                # Each of the following recipients was rejected by a remote
                # mail server.
                #
                #    Recipient: <******@ezweb.ne.jp>
                #    >>> RCPT TO:<******@ezweb.ne.jp>
                #    <<< 550 <******@ezweb.ne.jp>: User unknown
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

            } elsif( $e =~ m/\AStatus:[ ]*(\d[.]\d+[.]\d+)/i ) {
                # Status: 5.1.1
                # Status:5.2.0
                # Status: 5.1.0 (permanent failure)
                $v->{'status'} = $1;

            } elsif( $e =~ m/\AAction:[ ]*(.+)\z/i ) {
                # Action: failed
                $v->{'action'} = lc $1;

            } elsif( $e =~ m/\ARemote-MTA:[ ]*dns;[ ]*(.+)\z/i ) {
                # Remote-MTA: DNS; mx.example.jp
                $v->{'rhost'} = lc $1;

            } elsif( $e =~ m/\ALast-Attempt-Date:[ ]*(.+)\z/i ) {
                # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                $v->{'date'} = $1;

            } else {
                next if Sisimai::String->is_8bit( \$e );
                if( $e =~ m/\A\s+[>]{3}\s+([A-Z]{4})/ ) {
                    #    >>> RCPT TO:<******@ezweb.ne.jp>
                    $v->{'command'} = $1;

                } else {
                    # Check error message
                    if( grep { $e =~ $_ } @$rxmessages ) {
                        # Check with regular expressions of each error
                        $v->{'diagnosis'} .= ' '.$e;
                    } else {
                        # >>> 550
                        $v->{'alterrors'} .= ' '.$e;
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

        if( exists $e->{'alterrors'} && length $e->{'alterrors'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $e->{'alterrors'};
            if( $e->{'diagnosis'} =~ m/\A[-]+/ || $e->{'diagnosis'} =~ m/__\z/ ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $e->{'alterrors'} if length $e->{'alterrors'};
            }
            delete $e->{'alterrors'};
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( exists $mhead->{'x-spasign'} && $mhead->{'x-spasign'} eq 'NG' ) {
            # Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by EZweb)
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

        unless( $e->{'reason'} ) {
            unless( $e->{'recipient'} =~ m/[@]ezweb[.]ne[.]jp\z/ ) {
                $e->{'reason'} = 'userunknown';
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

Sisimai::MSP::JP::EZweb - bounce mail parser class for C<au EZweb>.

=head1 SYNOPSIS

    use Sisimai::MSP::JP::EZweb;

=head1 DESCRIPTION

Sisimai::MSP::JP::EZweb parses a bounce email which created by C<au EZweb>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::JP::EZweb->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::JP::EZweb->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::JP::EZweb->smtpagent;

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

