package Sisimai::MTA::Exchange;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'begin'    => qr/\AYour message/,
    'error'    => qr/\Adid not reach the following recipient[(]s[)]:/,
    'rfc822'   => qr|\AContent-Type: message/rfc822|,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'x-mailer' => [
        # X-Mailer: Internet Mail Service (5.0.1461.28)
        # X-Mailer: Microsoft Exchange Server Internet Mail Connector Version ...
        qr/\AInternet Mail Service [(][\d.]+[)]\z/,
        qr/\AMicrosoft Exchange Server Internet Mail Connector/,
    ],
    'x-mimeole' => [
        qr/\AProduced By Microsoft Exchange/,
    ],
    'received' => [
        # Received: by ***.**.** with Internet Mail Service (5.5.2657.72)
        qr/\Aby .+ with Internet Mail Service [(][\d.]+[)]/,
    ],
};

my $ErrorCodeTable = {
    'onhold' => [
        '000B099C', # Host Unknown, Message exceeds size limit, ...
        '000B09AA', # Unable to relay for, Message exceeds size limit,...
        '000B09B6', # Error messages by remote MTA
    ],
    'userunknown' => [
        '000C05A6', # Unknown Recipient,
    ],
    'systemerror' => [
        '00010256', # Too many recipients. 
        '000D06B5', # No proxy for recipient (non-smtp mail?)
        '00120270', # Too Many Hops
    ],
    'contenterr' => [
        '00050311', # Conversion to Internet format failed
        '000502CC', # Conversion to Internet format failed
    ],
    'securityerr' => [
        '000B0981', # 502 Server does not support AUTH
    ],
    'filtered' => [
        '000C0595', # Ambiguous Recipient
    ],
};

sub version     { '4.0.7' }
sub description { 'Microsoft Exchange Server' }
sub smtpagent   { 'Exchange' }
sub headerlist  { return [ 'X-MS-Embedded-Report', 'X-Mailer', 'X-MimeOLE' ] };

sub scan {
    # @Description  Detect an error from Microsoft Exchange Server
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match = 1 if defined $mhead->{'x-ms-embedded-report'};
    EXCHANGE_OR_NOT: while( 1 ) {
        # Check the value of X-Mailer header
        if( defined $mhead->{'x-mailer'} ) {
            # X-Mailer:  Microsoft Exchange Server Internet Mail Connector Version 4.0.994.63
            # X-Mailer: Internet Mail Service (5.5.2232.9)
            $match = 1 if grep { $mhead->{'x-mailer'} =~ $_ } @{ $RxMTA->{'x-mailer'} };
            last if $match;
        }

        if( defined $mhead->{'x-mimeole'} ) {
            # X-MimeOLE: Produced By Microsoft Exchange V6.5
            $match = 1 if grep { $mhead->{'x-mimeole'} =~ $_ } @{ $RxMTA->{'x-mimeole'} };
            last if $match;
        }

        last unless scalar @{ $mhead->{'received'} };
        for my $e ( @{ $mhead->{'received'} } ) {
            # Received: by ***.**.** with Internet Mail Service (5.5.2657.72)
            next unless grep { $e =~ $_ } @{ $RxMTA->{'received'} };
            $match = 1;
            last(EXCHANGE_OR_NOT);
        }
        last;
    }
    return undef unless $match;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $statuspart = 0;     # (Integer) Flag, 1 = have got delivery status part.
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'to'      => '',    # The value of "To"
        'date'    => '',    # The value of "Date"
        'subject' => '',    # The value of "Subject"
    };

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
            next if $statuspart;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # did not reach the following recipient(s):
                # 
                # kijitora@example.co.jp on Thu, 29 Apr 2007 16:51:51 -0500
                #     The recipient name is not recognized
                #     The MTS-ID of the original message is: c=jp;a= ;p=neko
                # ;l=EXCHANGE000000000000000000
                #     MSEXCH:IMS:KIJITORA CAT:EXAMPLE:EXCHANGE 0 (000C05A6) Unknown Recipient
                # mikeneko@example.co.jp on Thu, 29 Apr 2007 16:51:51 -0500
                #     The recipient name is not recognized
                #     The MTS-ID of the original message is: c=jp;a= ;p=neko
                # ;l=EXCHANGE000000000000000000
                #     MSEXCH:IMS:KIJITORA CAT:EXAMPLE:EXCHANGE 0 (000C05A6) Unknown Recipient
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A\s*([^ ]+[@][^ ]+) on\s*.*\z/ ||
                    $e =~ m/\A\s*.+SMTP=([^ ]+[@][^ ]+) on\s*.*\z/i ) {
                    # kijitora@example.co.jp on Thu, 29 Apr 2007 16:51:51 -0500
                    #   kijitora@example.com on 4/29/99 9:19:59 AM
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $v->{'msexch'} = 0;
                    $recipients++;

                } elsif( $e =~ m/\A\s+(MSEXCH:.+)\z/ ) {
                    #     MSEXCH:IMS:KIJITORA CAT:EXAMPLE:EXCHANGE 0 (000C05A6) Unknown Recipient
                    $v->{'diagnosis'} .= $1;

                } else {

                    next if $v->{'msexch'};
                    if( $v->{'diagnosis'} =~ m/\AMSEXCH:.+/ ) {
                        # Continued from MEEXCH in the previous line
                        $v->{'msexch'} = 1;
                        $v->{'diagnosis'} .= ' '.$e;
                        $statuspart = 1;

                    } else {
                        # Error message in the body part
                        $v->{'alterrors'} .= ' '.$e;
                    }
                }

            } else {
                # Your message
                #
                #  To:      shironeko@example.jp
                #  Subject: ...
                #  Sent:    Thu, 29 Apr 2010 18:14:35 +0000
                #
                if( $e =~ m/\A\s+To:\s+(.+)\z/ ) {
                    #  To:      shironeko@example.jp
                    next if length $connheader->{'to'};
                    $connheader->{'to'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A\s+Subject:\s+(.+)\z/ ) {
                    #  Subject: ...
                    next if length $connheader->{'subject'};
                    $connheader->{'subject'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A\s+Sent:\s+([A-Z][a-z]{2},.+[-+]\d{4})\z/ ||
                         $e =~ m|\A\s+Sent:\s+(\d+[/]\d+[/]\d+\s+\d+:\d+:\d+\s.+)|) {
                    #  Sent:    Thu, 29 Apr 2010 18:14:35 +0000
                    #  Sent:    4/29/99 9:19:59 AM
                    next if length $connheader->{'date'};
                    $connheader->{'date'} = $1;
                    $connvalues++;
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

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( $e->{'diagnosis'} =~ m{\AMSEXCH:.+\s*[(]([0-9A-F]{8})[)]\s*(.*)\z} ) {
            #     MSEXCH:IMS:KIJITORA CAT:EXAMPLE:EXCHANGE 0 (000C05A6) Unknown Recipient
            my $c = $1;
            my $d = $2;
            my $s = '';

            for my $r ( keys %$ErrorCodeTable ) {
                next unless grep { $c eq $_ } @{ $ErrorCodeTable->{ $r } };
                $e->{'reason'} = $r;
                $s = Sisimai::RFC3463->status( $r, 'p', 'i' );
                $e->{'status'} = $s if length $s;
                last;
            }
            $e->{'diagnosis'} = $d;
        }

        unless( $e->{'reason'} ) {
            # Could not detect the reason from the value of "diagnosis".
            if( exists $e->{'alterrors'} && length $e->{'alterrors'} ) {
                # Copy alternative error message
                $e->{'diagnosis'} = $e->{'alterrors'}.' '.$e->{'diagnosis'};
                $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );
                delete $e->{'alterrors'};
            }
        }

        $e->{'spec'}    = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'}  = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'agent'} ||= __PACKAGE__->smtpagent;

        delete $e->{'msexch'};

    } # end of for()

    if( length( $rfc822part ) == 0 ) {
        # When original message does not included in the bounce message
        $rfc822part .= sprintf( "From: %s\n", $connheader->{'to'} );
        $rfc822part .= sprintf( "Date: %s\n", $connheader->{'date'} );
        $rfc822part .= sprintf( "Subject: %s\n", $connheader->{'subject'} );
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Exchange - bounce mail parser class for C<Microsft Exchange 
Server>.

=head1 SYNOPSIS

    use Sisimai::MTA::Exchange;

=head1 DESCRIPTION

Sisimai::MTA::Exchange parses a bounce email which created by C<Microsoft
Exchange Server>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Exchange->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Exchange->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Exchange->smtpagent;

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
