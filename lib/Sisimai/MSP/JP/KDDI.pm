package Sisimai::MSP::JP::KDDI;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'       => qr/[<]?(?>postmaster[@]ezweb[.]ne[.]jp)[>]?/i,
    'reply-to'   => qr/[<]?.+[@]\w+[.]auone-net[.]jp[>]?\z/i,
    'received'   => qr/\Afrom[ ](?:.+[.])?ezweb[.]ne[.]jp[ ]/,
    'subject'    => qr/\AMail System Error - Returned Mail\z/,
    'message-id' => qr/[@].+[.]ezweb[.]ne[.]jp[>]\z/,
};

my $RxVia = [
    qr/\Afrom\s+ezweb[.]ne[.]jp\s/,
    qr/\Afrom\s+\w+[.]auone[-]net[.]jp\s/,
];

sub version     { '4.0.1' }
sub description { 'au by KDDI' }
sub smtpagent   { 'JP::KDDI' }
sub headerlist  { return [ 'X-SPASIGN' ] }

sub scan {
    # @Description  Detect an error from KDDI
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # Pre-process email headers of NON-STANDARD bounce message au by KDDI, as
    # known as ezweb.ne.jp.
    #   Subject: Mail System Error - Returned Mail
    #   From: <Postmaster@ezweb.ne.jp>
    #   Received: from ezweb.ne.jp (wmflb12na02.ezweb.ne.jp [222.15.69.197])
    #   Received: from nmomta.auone-net.jp ([aaa.bbb.ccc.ddd]) by ...
    #
    $match++ if $mhead->{'from'} =~ $RxMSP->{'from'};
    $match++ if $mhead->{'reply-to'} && $mhead->{'reply-to'} =~ $RxMSP->{'reply-to'};
    $match++ if $mhead->{'subject'} =~ $RxMSP->{'subject'};
    return undef unless( $match || scalar @{ $mhead->{'received'} } );

    for my $e ( @$RxVia ) {
        # Check each line of Received header
        next unless grep { $_ =~ $e } @{ $mhead->{'received'} };
        $match++;
    }
    return undef unless $match;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $softbounce = 0;     # (Integer) 1 = Soft bounce

    my $RxMTA      = {};    # (Ref->Hash) Delimiter patterns
    my $RxErr      = {};    # (Ref->Hash) Error message patterns

    my $v = undef;
    my $p = undef;
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::String;
    require Sisimai::RFC5322;
    require Sisimai::Address;

    if( ( grep { $_ =~ $RxMSP->{'received'} } @{ $mhead->{'received'} } )
        || ( $mhead->{'message-id'} =~ $RxMSP->{'message-id'} ) ) {
        # *@ezweb.ne.jp
        $RxMTA = {
            # The user(s) 
            'begin'  => [
                qr/\AThe user[(]s[)]\s/,
                qr/Your message\s/,
                qr/Each of the following|The following/,
                qr/[<][^ ]+[@][^ ]+[>]/,
            ],
            'rfc822' => qr/\A[-]{50}/,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $RxErr = {
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

        for my $e ( @$stripedtxt ) {
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
                next unless ( grep { $e =~ $_ } @{ $RxMTA->{'begin'} } ) .. ( $e =~ $RxMTA->{'rfc822'} );
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

                } else {
                    next if Sisimai::String->is_8bit( \$e );
                    if( $e =~ m/\A\s+[>]{3}\s+([A-Z]{4})/ ) {
                        #    >>> RCPT TO:<******@ezweb.ne.jp>
                        $v->{'command'} = $1;

                    } else {
                        $v->{'diagnosis'} .= $e.' ';
                    }
                }
            } # End of if: rfc822

        } continue {
            # Save the current line for the next loop
            $p = $e;
            $e = undef;
        }

    } else {
        # Bounced from auone-net.jp(DION)
        $RxMTA= {
            'begin'  => [
                qr/\AYour mail sent on:? [A-Z][a-z]{2}[,]/,
                qr/\AYour mail attempted to be delivered on:? [A-Z][a-z]{2}[,]/,
            ],
            'rfc822' => qr|\AContent-Type: message/rfc822\z|,
            'error'  => qr/Could not be delivered to:? /,
            'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
        };

        $RxErr = {
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

        for my $e ( @$stripedtxt ) {
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
                next unless ( grep { $e =~ $_ } @{ $RxMTA->{'begin'} } ) .. ( $e =~ $RxMTA->{'rfc822'} );
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
                    $v->{'diagnosis'} .= $e.' ';
                }
            } # End of if: rfc822

        } continue {
            # Save the current line for the next loop
            $p = $e;
            $e = undef;
        }
    }

    return undef unless $recipients;
    require Sisimai::RFC3463;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'date'}  ||= $mhead->{'date'};
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

                $e->{'reason'} = 'userunknown';

            } else {

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
        $e->{'command'} ||= 'CONN';

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
