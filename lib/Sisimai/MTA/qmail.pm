package Sisimai::MTA::qmail;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

#  qmail-remote.c:248|    if (code >= 500) {
#  qmail-remote.c:249|      out("h"); outhost(); out(" does not like recipient.\n");
#  qmail-remote.c:265|  if (code >= 500) quit("D"," failed on DATA command");
#  qmail-remote.c:271|  if (code >= 500) quit("D"," failed after I sent the message");
#
# Characters: K,Z,D in qmail-qmqpc.c, qmail-send.c, qmail-rspawn.c
#  K = success, Z = temporary error, D = permanent error
#
my $RxMTA = {
    'begin'    => qr/\AHi[.] This is the qmail/,
    'rfc822'   => qr/\A--- Below this line is a copy of the message[.]\z/,
    'error'    => qr/\ARemote host said:/,
    'sorry'    => qr/\A[Ss]orry[,.][ ]/,
    'subject'  => qr/\Afailure notice/,
    'received' => qr/\A[(]qmail[ ]+\d+[ ]+invoked[ ]+(?:for[ ]+bounce|from[ ]+network)[)]/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $RxSMTP = {
    'conn'  => qr{
        # Error text regular expressions which defined in qmail-remote.c
        # qmail-remote.c:225|  if (smtpcode() != 220) quit("ZConnected to "," but greeting failed");
        (?:Error:)?Connected[ ]to[ ].+[ ]but[ ]greeting[ ]failed[.]
    }x,
    'ehlo' => qr{
        # qmail-remote.c:231|  if (smtpcode() != 250) quit("ZConnected to "," but my name was rejected");
        (?:Error:)?Connected[ ]to[ ].+[ ]but[ ]my[ ]name[ ]was[ ]rejected[.]
    }x,
    'mail'  => qr{
        # qmail-remote.c:238|  if (code >= 500) quit("DConnected to "," but sender was rejected");
        # reason = rejected
        (?:Error:)?Connected[ ]to[ ].+[ ]but[ ]sender[ ]was[ ]rejected[.]
    }x,
    'rcpt'  => qr{
        # qmail-remote.c:249|  out("h"); outhost(); out(" does not like recipient.\n");
        # qmail-remote.c:253|  out("s"); outhost(); out(" does not like recipient.\n");
        # reason = userunknown
        (?:Error:)?.+[ ]does[ ]not[ ]like[ ]recipient[.]
    },
    'data'  => qr{(?:
         (?:Error:)?.+[ ]failed[ ]on[ ]DATA[ ]command[.]
        # qmail-remote.c:265|  if (code >= 500) quit("D"," failed on DATA command");
        # qmail-remote.c:266|  if (code >= 400) quit("Z"," failed on DATA command");
        |(?:Error:)?.+[ ]failed[ ]after[ ]I[ ]sent[ ]the[ ]message[.]
        # qmail-remote.c:271|  if (code >= 500) quit("D"," failed after I sent the message");
        # qmail-remote.c:272|  if (code >= 400) quit("Z"," failed after I sent the message");
        )
    }x,
};

my $RxComm = qr/
    # qmail-remote-fallback.patch
    Sorry,[ ]no[ ]SMTP[ ]connection[ ]got[ ]far[ ]enough;[ ]most[ ]progress[ ]was[ ]([A-Z]{4})[ ]
/x;

my $RxHost = qr{(?:
    # qmail-remote.c:261|  if (!flagbother) quit("DGiving up on ","");
     Giving[ ]up[ ]on[ ](.+[0-9a-zA-Z])[.]?\z
    |Connected[ ]to[ ]([-0-9a-zA-Z.]+[0-9a-zA-Z])[ ]
    |remote[ ]host[ ]([-0-9a-zA-Z.]+[0-9a-zA-Z])[ ]said:
    )
}x;

my $RxSess = {
    # 'onhold' => qr//,
    'userunknown' => qr{(?:
        # qmail-local.c:589|  strerr_die1x(100,"Sorry, no mailbox here by that name. (#5.1.1)");
         no[ ]mailbox[ ]here[ ]by[ ]that[ ]name
        # qmail-remote.c:253|  out("s"); outhost(); out(" does not like recipient.\n");
        |[ ]does[ ]not[ ]like[ ]recipient[.]
        )
    }x,
    'mailboxfull' => qr{
        # error_str.c:192|  X(EDQUOT,"disk quota exceeded")
        disk[ ]quota[ ]exceeded
    }x,
    'mesgtoobig' => qr{
        # qmail-qmtpd.c:233| ... result = "Dsorry, that message size exceeds my databytes limit (#5.3.4)";
        # qmail-smtpd.c:391| ... out("552 sorry, that message size exceeds my databytes limit (#5.3.4)\r\n"); return;
        Message[ ]size[ ]exceeds[ ]fixed[ ]maximum[ ]message[ ]size:
    }x,
    'hostunknown' => qr{
        # qmail-remote.c:68|  Sorry, I couldn't find any host by that name. (#4.1.2)\n"); zerodie();
        # qmail-remote.c:78|  Sorry, I couldn't find any host named ");
        \ASorry[,][ ]I[ ]couldn[']t[ ]find[ ]any[ ]host[ ]
    }x,
    'systemerror' => qr{(?>
         bad[ ]interpreter:[ ]No[ ]such[ ]file[ ]or[ ]directory
        |system[ ]error
        |Unable[ ]to\b
        )
    }x,
    'networkerror' => qr{Sorry(?:
         [,][ ]I[ ]wasn[']t[ ]able[ ]to[ ]establish[ ]an[ ]SMTP[ ]connection
        |[,][ ]I[ ]couldn[']t[ ]find[ ]a[ ]mail[ ]exchanger[ ]or[ ]IP[ ]address
        |[.][ ]Although[ ]I[']m[ ]listed[ ]as[ ]a[ ]best[-]preference[ ]MX[ ]
            or[ ]A[ ]for[ ]that[ ]host
        )
    }x,
    'systemfull' => 
        qr/Requested action not taken: mailbox unavailable [(]not enough free space[)]/,
};

my $RxExpr = qr{
    # qmail-send.c:922| ... (&dline[c],"I'm not going to try again; this message has been in the queue too long.\n")) nomem();
    this[ ]message[ ]has[ ]been[ ]in[ ]the[ ]queue[ ]too[ ]long[.]\z
}x;

my $RxLDAP = {
    # qmail-ldap-1.03-20040101.patch:19817 - 19866
    'suspend'     => qr/Mailaddress is administrative?le?y disabled/,            # 5.2.1
    'userunknown' => qr/[Ss]orry, no mailbox here by that name/,                 # 5.1.1
    'exceedlimit' => qr/The message exeeded the maximum size the user accepts/,  # 5.2.3
    'systemerror' => qr{(?>
         Automatic[ ]homedir[ ]creator[ ]crashed                    # 4.3.0
        |Illegal[ ]value[ ]in[ ]LDAP[ ]attribute                    # 5.3.5
        |LDAP[ ]attribute[ ]is[ ]not[ ]given[ ]but[ ]mandatory      # 5.3.5
        |Timeout[ ]while[ ]performing[ ]search[ ]on[ ]LDAP[ ]server # 4.4.3
        |Too[ ]many[ ]results[ ]returned[ ]but[ ]needs[ ]to[ ]be[ ]unique # 5.3.5
        |Permanent[ ]error[ ]while[ ]executing[ ]qmail[-]forward    # 5.4.4
        |Temporary[ ](?:
             error[ ](?:
                 in[ ]automatic[ ]homedir[ ]creation            # 4.3.0 or 5.3.0
                |while[ ]executing[ ]qmail[-]forward            # 4.4.4
                )
            |failure[ ]in[ ]LDAP[ ]lookup                       # 4.4.3
            )
        |Unable[ ]to[ ](?:
             contact[ ]LDAP[ ]server                            # 4.4.3
            |login[ ]into[ ]LDAP[ ]server,[ ]bad[ ]credentials  # 4.4.3
            )
        )
    }x,
};

# userunknown + expired
my $RxOnHold = qr/\A[^ ]+ does not like recipient[.]\s+.+this message has been in the queue too long[.]\z/;

sub version     { '4.1.1' }
sub description { 'qmail' }
sub smtpagent   { 'qmail' }

sub scan {
    # @Description  Detect an error from qmail
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # Pre process email headers and the body part of the message which generated
    # by qmail, see http://cr.yp.to/qmail.html
    #   e.g.) Received: (qmail 12345 invoked for bounce); 29 Apr 2009 12:34:56 -0000
    #         Subject: failure notice
    $match = 1 if lc( $mhead->{'subject'} ) =~ $RxMTA->{'subject'};
    $match = 1 if grep { $_ =~ $RxMTA->{'received'} } @{ $mhead->{'received'} };
    return undef unless $match;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my @stripedtxt = split( "\n", $$mbody );
    my $longfields = __PACKAGE__->LONGFIELDS;

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
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
            next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
            next unless length $e;

            # <kijitora@example.jp>:
            # 192.0.2.153 does not like recipient.
            # Remote host said: 550 5.1.1 <kijitora@example.jp>... User Unknown
            # Giving up on 192.0.2.153.
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A(?:To[ ]*:)?[<](.+[@].+)[>]:\s*\z/ ) {
                # <kijitora@example.jp>:
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( scalar @$dscontents == $recipients ) {
                # Append error message
                next unless length $e;
                $v->{'diagnosis'} .= $e.' ';
                $v->{'alterrors'}  = $e if $e =~ $RxMTA->{'error'};

                next if $v->{'rhost'};
                $v->{'rhost'} = $1 if $e =~ $RxHost;
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
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( ! $e->{'command'} ) {

            COMMAND: while(1) {
                # Get the SMTP command name for the session
                SMTP: for my $r ( keys %$RxSMTP ) {
                    # Verify each regular expression of SMTP commands
                    next unless $e->{'diagnosis'} =~ $RxSMTP->{ $r };
                    $e->{'command'} = uc $r;
                    last(COMMAND);
                }

                # Verify each regular expression of patches
                $e->{'command'} = uc $1 if $e->{'diagnosis'} =~ $RxComm;
                last;
            }
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
                # Try to match with each error message in the table
                if( $e->{'diagnosis'} =~ $RxOnHold ) {
                    # To decide the reason require pattern match with 
                    # Sisimai::Reason::* modules
                    $e->{'reason'} = 'onhold';

                } else {

                    SESSION: for my $r ( keys %$RxSess ) {
                        # Verify each regular expression of session errors
                        if( $e->{'alterrors'} ) {
                            # Check the value of "alterrors"
                            next unless $e->{'alterrors'} =~ $RxSess->{ $r };
                            $e->{'reason'} = $r;
                        }
                        last(SESSION) if $e->{'reason'};

                        next unless $e->{'diagnosis'} =~ $RxSess->{ $r };
                        $e->{'reason'} = $r;
                        last(SESSION);
                    }

                    LDAP: for my $r ( keys %$RxLDAP ) {
                        # Verify each regular expression of LDAP errors
                        next unless $e->{'diagnosis'} =~ $RxLDAP->{ $r };
                        $e->{'reason'} = $r;
                        last(LDAP);
                    }

                    last if $e->{'reason'};
                    $e->{'reason'} = 'expired' if $e->{'diagnosis'} =~ $RxExpr;
                }
            }
            last;
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'command'} ||= '';

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::qmail - bounce mail parser class for C<qmail>.

=head1 SYNOPSIS

    use Sisimai::MTA::qmail;

=head1 DESCRIPTION

Sisimai::MTA::qmail parses a bounce email which created by C<qmail>. Methods in
the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::qmail->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::qmail->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::qmail->smtpagent;

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
