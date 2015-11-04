package Sisimai::MTA::MXLogic;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# Based on Sisimai::MTA::Exim
my $RxMTA = {
    'from'    => qr/\AMail Delivery System/,
    'rfc822'  => qr/\AIncluded is a copy of the message header:\z/,
    'begin'   => qr/\AThis message was created automatically by mail delivery software[.]\z/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'   => qr{(?:
         Mail[ ]delivery[ ]failed(:[ ]returning[ ]message[ ]to[ ]sender)?
        |Warning:[ ]message[ ].+[ ]delayed[ ]+
        |Delivery[ ]Status[ ]Notification
        )
    }x,
    'message-id' => qr/\A[<]mxl[~][0-9a-f]+/,
};

my $RxComm = [
    qr/SMTP error from remote (?:mail server|mailer) after ([A-Za-z]{4})/,
    qr/SMTP error from remote (?:mail server|mailer) after end of ([A-Za-z]{4})/,
];

my $RxSess = {
    'expired' => qr{(?:
         retry[ ]timeout[ ]exceeded
        |No[ ]action[ ]is[ ]required[ ]on[ ]your[ ]part
        )
    }x,
    'userunknown' => qr{
        user[ ]not[ ]found
    }x,
    'hostunknown' => qr{(?>
         all[ ](?:
             host[ ]address[ ]lookups[ ]failed[ ]permanently
            |relevant[ ]MX[ ]records[ ]point[ ]to[ ]non[-]existent[ ]hosts
            )
        |Unrouteable[ ]address
        )
    }x,
    'mailboxfull' => qr{(?:
         mailbox[ ]is[ ]full:?
        |error:[ ]quota[ ]exceed
        )
    }x,
    'notaccept' => qr{(?:
         an[ ]MX[ ]or[ ]SRV[ ]record[ ]indicated[ ]no[ ]SMTP[ ]service
        |no[ ]host[ ]found[ ]for[ ]existing[ ]SMTP[ ]connection
        )
    }x,
    'systemerror' => qr{(?>
         delivery[ ]to[ ](?:file|pipe)[ ]forbidden
        |local[ ]delivery[ ]failed
        )
    }x,
    'contenterror' => qr{
        Too[ ]many[ ]["]Received["][ ]headers[ ]
    }x,
};

sub description { 'McAfee SaaS' }
sub smtpagent   { 'MXLogic' }
sub headerlist  { return [ 'X-MXL-NoteHash', 'X-MXL-Hash' ] }

sub scan {
    # Detect an error from MXLogic
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
    # @since v4.1.1
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match = 1 if defined $mhead->{'x-mxl-hash'};
    $match = 1 if defined $mhead->{'x-mxl-notehash'};
    $match = 1 if $mhead->{'subject'} =~ $RxMTA->{'subject'};
    $match = 1 if $mhead->{'from'}    =~ $RxMTA->{'from'};
    return undef unless $match;

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
    my $localhost0 = '';    # (String) Local MTA

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor = $indicators->{'deliverystatus'} if $e =~ $RxMTA->{'begin'};
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor = $indicators->{'message-rfc822'} if $e =~ $RxMTA->{'rfc822'};
        }

        if( $readcursor & $indicators->{'message-rfc822'} ) {
            # After "message/rfc822"
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

        } else {
            # Before "message/rfc822"
            next unless $readcursor & $indicators->{'deliverystatus'};
            next unless length $e;

            # This message was created automatically by mail delivery software.
            #
            # A message that you sent could not be delivered to one or more of its
            # recipients. This is a permanent error. The following address(es) failed:
            #
            #  kijitora@example.jp
            #    SMTP error from remote mail server after RCPT TO:<kijitora@example.jp>:
            #    host neko.example.jp [192.0.2.222]: 550 5.1.1 <kijitora@example.jp>... User Unknown
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\s*This is a permanent error[.]\s*/ ) {
                # deliver.c:6811|  "recipients. This is a permanent error. The following address(es) failed:\n");
                $v->{'softbounce'} = 0;

            } elsif( $e =~ m/\A\s*[<]([^ ]+[@][^ ]+)[>]:(.+)\z/ ) {
                # A message that you have sent could not be delivered to one or more
                # recipients.  This is a permanent error.  The following address failed:
                #
                #  <kijitora@example.co.jp>: 550 5.1.1 ...
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $2;
                $recipients++;

            } elsif( scalar @$dscontents == $recipients ) {
                # Error message
                next unless length $e;
                $v->{'diagnosis'} .= $e.' ';
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }
    return undef unless $recipients;

    if( scalar @{ $mhead->{'received'} } ) {
        # Get the name of local MTA
        # Received: from marutamachi.example.org (c192128.example.net [192.0.2.128])
        $localhost0 = $1 if $mhead->{'received'}->[-1] =~ m/from\s([^ ]+) /;
    }

    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'}   = __PACKAGE__->smtpagent;
        $e->{'lhost'} ||= $localhost0;

        $e->{'diagnosis'} =~ s/[-]{2}.*\z//g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        if( ! $e->{'rhost'} ) {
            # Get the remote host name
            if( $e->{'diagnosis'} =~ m/host\s+([^\s]+)\s\[.+\]:\s/ ) {
                # host neko.example.jp [192.0.2.222]: 550 5.1.1 <kijitora@example.jp>... User Unknown
                $e->{'rhost'} = $1;
            }

            unless( $e->{'rhost'} ) {
                if( scalar @{ $mhead->{'received'} } ) {
                    # Get localhost and remote host name from Received header.
                    my $r = $mhead->{'received'};
                    $e->{'rhost'} = pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
                }
            }
        }

        if( ! $e->{'command'} ) {

            COMMAND: while(1) {
                # Get the SMTP command name for the session
                SMTP: for my $r ( @$RxComm ) {
                    # Verify each regular expression of SMTP commands
                    next unless $e->{'diagnosis'} =~ $r;
                    $e->{'command'} = uc $1;
                    last(COMMAND);
                }
                last;
            }

            REASON: while(1) {
                # Detect the reason of bounce
                if( $e->{'command'} eq 'MAIL' ) {
                    # MAIL | Connected to 192.0.2.135 but sender was rejected.
                    $e->{'reason'} = 'rejected';

                } elsif( $e->{'command'} =~ m/\A(?:HELO|EHLO)\z/ ) {
                    # HELO | Connected to 192.0.2.135 but my name was rejected.
                    $e->{'reason'} = 'blocked';

                } else {

                    SESSION: for my $r ( keys %$RxSess ) {
                        # Verify each regular expression of session errors
                        next unless $e->{'diagnosis'} =~ $RxSess->{ $r };
                        $e->{'reason'} = $r;
                        last;
                    }
                }
                last;
            }
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'} = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'command'} ||= '';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::MXLogic - bounce mail parser class for C<MX Logic>.

=head1 SYNOPSIS

    use Sisimai::MTA::MXLogic;

=head1 DESCRIPTION

Sisimai::MTA::MXLogic parses a bounce email which created by C<McAfee SaaS 
(formerly MX Logic)>. Methods in the module are called from only 
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::MXLogic->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::MXLogic->smtpagent;

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
