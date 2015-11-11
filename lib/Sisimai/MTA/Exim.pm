package Sisimai::MTA::Exim;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'from'      => qr/\AMail Delivery System/,
    'subject'   => qr{(?:
         Mail[ ]delivery[ ]failed(:[ ]returning[ ]message[ ]to[ ]sender)?
        |Warning:[ ]message[ ].+[ ]delayed[ ]+
        |Delivery[ ]Status[ ]Notification
        |Mail[ ]failure
        |Message[ ]frozen
        |error[(]s[)][ ]in[ ]forwarding[ ]or[ ]filtering
        )
    }x,
    'message-id'=> qr/\A[<]\w+[-]\w+[-]\w+[@].+\z/,
    # Message-Id: <E1P1YNN-0003AD-Ga@example.org>
};

# Error text regular expressions which defined in exim/src/deliver.c
#
# deliver.c:6292| fprintf(f,
# deliver.c:6293|"This message was created automatically by mail delivery software.\n");
# deliver.c:6294|        if (to_sender)
# deliver.c:6295|          {
# deliver.c:6296|          fprintf(f,
# deliver.c:6297|"\nA message that you sent could not be delivered to one or more of its\n"
# deliver.c:6298|"recipients. This is a permanent error. The following address(es) failed:\n");
# deliver.c:6299|          }
# deliver.c:6300|        else
# deliver.c:6301|          {
# deliver.c:6302|          fprintf(f,
# deliver.c:6303|"\nA message sent by\n\n  <%s>\n\n"
# deliver.c:6304|"could not be delivered to one or more of its recipients. The following\n"
# deliver.c:6305|"address(es) failed:\n", sender_address);
# deliver.c:6306|          }
#
# deliver.c:6423|          if (bounce_return_body) fprintf(f,
# deliver.c:6424|"------ This is a copy of the message, including all the headers. ------\n");
# deliver.c:6425|          else fprintf(f,
# deliver.c:6426|"------ This is a copy of the message's headers. ------\n");
my $Re1 = {
    'alias'  => qr/\A([ ]+an[ ]undisclosed[ ]address)\z/,
    'frozen' => qr/\AMessage .+ (?:has been frozen|was frozen on arrival)/,
    'rfc822' => qr{\A(?:
                     [-]+[ ]This[ ]is[ ]a[ ]copy[ ]of[ ]the[ ]message.+headers[.][ ][-]+
                    |Content-Type:[ ]*message/rfc822
                    )\z
                }x,
    'begin'  => qr{\A(?>
                     This[ ]message[ ]was[ ]created[ ]automatically[ ]by[ ]mail[ ]delivery[ ]software[.]
                    |A[ ]message[ ]that[ ]you[ ]sent[ ]was[ ]rejected[ ]by[ ]the[ ]local[ ]scanning[ ]code
                    |Message[ ].+[ ](?:has[ ]been[ ]frozen|was[ ]frozen[ ]on[ ]arrival)
                    |The[ ].+[ ]router[ ]encountered[ ]the[ ]following[ ]error[(]s[)]:
                    )
                   }x,
    'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $ReCommand = [
    # transports/smtp.c:564|  *message = US string_sprintf("SMTP error from remote mail server after %s%s: "
    # transports/smtp.c:837|  string_sprintf("SMTP error from remote mail server after RCPT TO:<%s>: "
    qr/SMTP error from remote (?:mail server|mailer) after ([A-Za-z]{4})/,
    qr/SMTP error from remote (?:mail server|mailer) after end of ([A-Za-z]{4})/,
    qr/LMTP error after ([A-Za-z]{4})/,
    qr/LMTP error after end of ([A-Za-z]{4})/,
];

my $ReFailure = {
    # find exim/ -type f -exec grep 'message = US' {} /dev/null \;
    'userunknown' => qr{
        # route.c:1158|  DEBUG(D_uid) debug_printf("getpwnam() returned NULL (user not found)\n");
        user[ ]not[ ]found
    }x,
    'hostunknown' => qr{(?>
         all[ ](?:
            # transports/smtp.c:3524|  addr->message = US"all host address lookups failed permanently";
             host[ ]address[ ]lookups[ ]failed[ ]permanently
            # routers/dnslookup.c:331|  addr->message = US"all relevant MX records point to non-existent hosts";
            |relevant[ ]MX[ ]records[ ]point[ ]to[ ]non[-]existent[ ]hosts
            )
        # route.c:1826|  uschar *message = US"Unrouteable address";
        |Unrouteable[ ]address
        )
    }x,
    'mailboxfull' => qr{(?:
        # transports/appendfile.c:2567|  addr->user_message = US"mailbox is full";
         mailbox[ ]is[ ]full:?
        # transports/appendfile.c:3049|  addr->message = string_sprintf("mailbox is full "$                          
        # transports/appendfile.c:3050|  "(quota exceeded while writing to file %s)", filename);$
        |error:[ ]quota[ ]exceed
        )
    }x,
    'notaccept' => qr{(?:
        # routers/dnslookup.c:328|  addr->message = US"an MX or SRV record indicated no SMTP service";
         an[ ]MX[ ]or[ ]SRV[ ]record[ ]indicated[ ]no[ ]SMTP[ ]service
        # transports/smtp.c:3502|  addr->message = US"no host found for existing SMTP connection";
        |no[ ]host[ ]found[ ]for[ ]existing[ ]SMTP[ ]connection
        )
    }x,
    'systemerror' => qr{(?>
        # deliver.c:5614|  addr->message = US"delivery to file forbidden";
        # deliver.c:5624|  addr->message = US"delivery to pipe forbidden";
         delivery[ ]to[ ](?:file|pipe)[ ]forbidden
        # transports/pipe.c:1156|  addr->user_message = US"local delivery failed";
        |local[ ]delivery[ ]failed
        |LMTP[ ]error[ ]after[ ]
        )
    }x,
    'contenterror' => qr{
        # deliver.c:5425|  new->message = US"Too many \"Received\" headers - suspected mail loop";
        Too[ ]many[ ]["]Received["][ ]headers
    }x,
};

my $ReDelayed = qr{(?:
    # retry.c:902|  addr->message = (addr->message == NULL)? US"retry timeout exceeded" :
     retry[ ]timeout[ ]exceeded
    # deliver.c:7475|  "No action is required on your part. Delivery attempts will continue for\n"
    |No[ ]action[ ]is[ ]required[ ]on[ ]your[ ]part
    # smtp.c:3508|  US"retry time not reached for any host after a long failure period" :
    # smtp.c:3508|  US"all hosts have been failing for a long time and were last tried "
    #                 "after this message arrived";
    |retry[ ]time[ ]not[ ]reached[ ]for[ ]any[ ]host[ ]after[ ]a[ ]long[ ]failure[ ]period
    |all[ ]hosts[ ]have[ ]been[ ]failing[ ]for[ ]a[ ]long[ ]time[ ]and[ ]were[ ]last[ ]tried
    # deliver.c:7459|  print_address_error(addr, f, US"Delay reason: ");
    |Delay[ ]reason:[ ]
    # deliver.c:7586|  "Message %s has been frozen%s.\nThe sender is <%s>.\n", message_id,
    # receive.c:4021|  moan_tell_someone(freeze_tell, NULL, US"Message frozen on arrival",
    # receive.c:4022|  "Message %s was frozen on arrival by %s.\nThe sender is <%s>.\n",
    |Message[ ].+[ ](?:has[ ]been[ ]frozen|was[ ]frozen[ ]on[ ]arrival[ ]by[ ])
    )
}x;

sub description { 'Exim' }
sub smtpagent   { 'Exim' }
sub headerlist  { return [ 'X-Failed-Recipients' ] }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from Exim
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
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $Re0->{'subject'};
    return undef unless $mhead->{'from'}    =~ $Re0->{'from'};

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
    my $boundary00 = '';    # (String) Boundary string
    my $rxboundary = undef; # (String) Regular expression for matching with the boundary

    my $v = undef;
    my $p = '';

    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;
    if( $mhead->{'content-type'} ) {
        # Get the boundary string and set regular expression for matching with
        # the boundary string.
        require Sisimai::MIME;
        $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
        $rxboundary = qr/\A[-]{2}$boundary00\z/ if length $boundary00;
    }

    for my $e ( @stripedtxt ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        last if $e =~ $Re1->{'endof'};

        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $Re1->{'begin'} ) {
                $readcursor |= $indicators->{'deliverystatus'};
                next unless $e =~ $Re1->{'frozen'};
            }
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $Re1->{'rfc822'} ) {
                $readcursor |= $indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $indicators->{'message-rfc822'} ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;
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

            } elsif( $e =~ m/\A\s+([^\s\t]+[@][^\s\t]+[.][a-zA-Z]+)(:.+)?\z/ || $e =~ $Re1->{'alias'} ) {
                #   kijitora@example.jp
                #   sabineko@example.jp: forced freeze
                #
                # deliver.c:4549|  printed = US"an undisclosed address";
                #   an undisclosed address
                #     (generated from kijitora@example.jp)
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( $e =~ m/\A[ ]+[(]generated[ ]from[ ](.+)[)]\z/ ||
                     $e =~ m/\A[ ]+generated[ ]by[ ]([^\s\t]+[@][^\s\t]+)/ ) {
                #     (generated from kijitora@example.jp)
                #  pipe to |/bin/echo "Some pipe output"
                #    generated by userx@myhost.test.ex
                $v->{'alias'} = $1;

            } else {
                next unless length $e;

                if( $e =~ $Re1->{'frozen'} ) {
                    # Message *** has been frozen by the system filter.
                    # Message *** was frozen on arrival by ACL.
                    $v->{'alterrors'} .= $e.' ';

                } else {
                    if( length $boundary00 ) {
                        # --NNNNNNNNNN-eximdsn-MMMMMMMMMM
                        # Content-type: message/delivery-status
                        # ...
                        if( $e =~ m/\A[Rr]eporting-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                            # Reporting-MTA: dns; mx.example.jp
                            $v->{'lhost'} = $1;

                        } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                            # Action: failed
                            $v->{'action'} = lc $1;

                        } elsif( $e =~ m/\A[Ss]tatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                            # Status: 5.0.0
                            $v->{'status'} = $1;

                        } elsif( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                            # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                            $v->{'spec'} = uc $1;
                            $v->{'diagnosis'} = $2;

                        } elsif( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*(.+)\z/ ) {
                            # Final-Recipient: rfc822;|/bin/echo "Some pipe output"
                            my $c = $1;
                            $v->{'spec'} ||= $c =~ m/[@]/ ? 'SMTP' : 'X-UNIX';

                        } else {
                            # Error message ?
                            $v->{'alterrors'} .= $e.' ' if $e =~ m/\A[ ]+/;
                        }

                    } else {
                        if( scalar @$dscontents == $recipients ) {
                            # Error message
                            next unless length $e;
                            $v->{'diagnosis'} .= $e.' ';

                        } else {
                            # Error message when email address above does not include '@'
                            # and domain part.
                            next unless $e =~ m/\A\s{4}/;
                            $v->{'alterrors'} .= $e.' ';
                        }
                    }
                }
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    if( $recipients ) {
        # Check "an undisclosed address", "unroutable address"
        for my $q ( @$dscontents ) {
            # Replace the recipient address with the value of "alias"
            next unless $q->{'alias'};
            if( length( $q->{'recipient'} ) == 0 || $q->{'recipient'} !~ m/[@]/ ) {
                # The value of "recipient" is empty or does not include "@"
                $q->{'recipient'} = $q->{'alias'};
            }
        }

    } else {
        # Fallback for getting recipient addresses
        if( defined $mhead->{'x-failed-recipients'} ) {
            # X-Failed-Recipients: kijitora@example.jp
            my @rcptinhead = split( ',', $mhead->{'x-failed-recipients'} );
            map { $_ =~ y/ //d } @rcptinhead;
            $recipients = scalar @rcptinhead;

            for my $e ( @rcptinhead ) {
                # Insert each recipient address into @$dscontents
                $dscontents->[-1]->{'recipient'} = $e;
                next if scalar @$dscontents == $recipients;
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
            }
        }
    }
    return undef unless $recipients;

    if( scalar @{ $mhead->{'received'} } ) {
        # Get the name of local MTA
        # Received: from marutamachi.example.org (c192128.example.net [192.0.2.128])
        $localhost0 = $1 if $mhead->{'received'}->[-1] =~ m/from\s([^ ]+) /;
    }

    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5321;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'}   = __PACKAGE__->smtpagent;
        $e->{'lhost'} ||= $localhost0;

        unless( $e->{'diagnosis'} ) {
            # Empty Diagnostic-Code: or error message
            if( $boundary00 ) {
                # --NNNNNNNNNN-eximdsn-MMMMMMMMMM
                # Content-type: message/delivery-status
                #
                # Reporting-MTA: dns; the.local.host.name
                #
                # Action: failed
                # Final-Recipient: rfc822;/a/b/c
                # Status: 5.0.0
                #
                # Action: failed
                # Final-Recipient: rfc822;|/p/q/r
                # Status: 5.0.0
                $e->{'diagnosis'} = $dscontents->[0]->{'diagnosis'} || '';
                $e->{'spec'}    ||= $dscontents->[0]->{'spec'};

                if( $dscontents->[0]->{'alterrors'} ) {
                    # The value of "alterrors" is also copied
                    $e->{'alterrors'} = $dscontents->[0]->{'alterrors'};
                }
            }
        }

        if( exists $e->{'alterrors'} && length $e->{'alterrors'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $e->{'alterrors'};
            if( $e->{'diagnosis'} =~ m/\A[-]+/ || $e->{'diagnosis'} =~ m/__\z/ ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $e->{'alterrors'} if length $e->{'alterrors'};

            } else {
                # Check the both value and try to match 
                if( length( $e->{'diagnosis'} ) < length( $e->{'alterrors'} ) ) {
                    # Check the value of alterrors
                    my $rxdiagnosis = qr/$e->{'diagnosis'}/i;
                    if( $e->{'alterrors'} =~ $rxdiagnosis ) {
                        # Override the value of diagnostic code message because
                        # the value of alterrors includes the value of diagnosis.
                        $e->{'diagnosis'} = $e->{'alterrors'};
                    }
                }
            }
            delete $e->{'alterrors'};
        }
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );
        $e->{'diagnosis'} =~ s{\b__.+\z}{};

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
            # Get the SMTP command name for the session
            SMTP: for my $r ( @$ReCommand ) {
                # Verify each regular expression of SMTP commands
                next unless $e->{'diagnosis'} =~ $r;
                $e->{'command'} = uc $1;
                last;
            }

            REASON: while(1) {
                # Detect the reason of bounce
                if( $e->{'command'} =~ m/\A(?:HELO|EHLO)\z/ ) {
                    # HELO | Connected to 192.0.2.135 but my name was rejected.
                    $e->{'reason'} = 'blocked';

                } elsif( $e->{'command'} eq 'MAIL' ) {
                    # MAIL | Connected to 192.0.2.135 but sender was rejected.
                    # $e->{'reason'} = 'rejected';
                    $e->{'reason'} = 'onhold';

                } else {
                    # Verify each regular expression of session errors
                    SESSION: for my $r ( keys %$ReFailure ) {
                        # Check each regular expression
                        next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
                        $e->{'reason'} = $r;
                        last(SESSION);
                    }
                    last if $e->{'reason'};

                    if( $e->{'diagnosis'} =~ $ReDelayed ) {
                        # The reason "expired"
                        $e->{'reason'} = 'expired';
                    }
                }
                last;
            }
        }

        STATUS: {
            # Prefer the value of smtp reply code in Diagnostic-Code:
            # See eg/maildir-as-a-sample/new/exim-20.eml
            #   Action: failed
            #   Final-Recipient: rfc822;userx@test.ex
            #   Status: 5.0.0
            #   Remote-MTA: dns; 127.0.0.1
            #   Diagnostic-Code: smtp; 450 TEMPERROR: retry timeout exceeded
            # The value of "Status:" indicates permanent error but the value
            # of SMTP reply code in Diagnostic-Code: field is "TEMPERROR"!!!!
            my $sv = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} ) || '';
            my $rv = Sisimai::RFC5321->getrc( $e->{'diagnosis'} )  || '';
            my $s1 = 0; # First character of Status as integer
            my $r1 = 0; # First character of SMTP reply code as integer
            my $v1 = 0;

            # "Status:" field did not exist in the bounce message
            unless( length $sv ) {
                # Check SMTP reply code
                if( length $rv ) {
                    # Generate pseudo DSN code from SMTP reply code
                    $r1 = substr( $rv, 0, 1 );
                    if( $r1 == 4 ) {
                        # Get the internal DSN(temporary error)
                        $sv = Sisimai::RFC3463->status( $e->{'reason'}, 't', 'i' );

                    } elsif( $r1 == 5 ) {
                        # Get the internal DSN(permanent error)
                        $sv = Sisimai::RFC3463->status( $e->{'reason'}, 'p', 'i' );
                    }
                }
            }

            $s1  = substr( $sv, 0, 1 ) if length $sv;
            $v1  = $s1 + $r1;
            $v1 += substr( $e->{'status'}, 0, 1 ) if length $e->{'status'};

            if( $v1 > 0 ) {
                # Status or SMTP reply code exists
                if( $v1 % 5 == 0 ) {
                    # Both "Status" and SMTP reply code indicate permanent error
                    $e->{'softbounce'} = 0;

                } elsif( $v1 % 4 == 0 ) {
                    # Both "Status" and SMTP reply code indicate temporary error
                    $e->{'softbounce'} = 1;

                } else {
                    # Mismatch error type...?
                    if( $r1 > 0 ) {
                        # Set pseudo DSN into the value of "status" accessor 
                        $e->{'status'} = $sv;
                        $e->{'softbounce'} = $r1 == 4 ? 1 : 0;
                    }
                }
            } else {
                # Neither Status nor SMTP reply code exist
                if( $e->{'reason'} =~ m/\A(?:expired|mailboxfull)/ ) {
                    # Set pseudo DSN (temporary error)
                    $sv = Sisimai::RFC3463->status( $e->{'reason'}, 't', 'i' );
                    $e->{'softbounce'} = 1;

                } else {
                    # Set pseudo DSN (permanent error)
                    $sv = Sisimai::RFC3463->status( $e->{'reason'}, 'p', 'i' );
                    $e->{'softbounce'} = 0;
                }
            }
            $e->{'status'} ||= $sv;
        }

        $e->{'action'}  ||= 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'command'} ||= '';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Exim - bounce mail parser class for C<Exim>.

=head1 SYNOPSIS

    use Sisimai::MTA::Exim;

=head1 DESCRIPTION

Sisimai::MTA::Exim parses a bounce email which created by C<Exim>. Methods in 
the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Exim->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Exim->smtpagent;

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
