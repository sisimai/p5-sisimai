package Sisimai::MTA::Exim;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

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
#
my $RxMTA = {
    'from'      => qr/\AMail Delivery System/,
    'rfc822'    => qr/\A------ This is a copy of the message.+headers[.] ------\z/,
    'begin'     => qr/\AThis message was created automatically by mail delivery software[.]/,
    'endof'     => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'   => [
        qr/Mail delivery failed(:?: returning message to sender)?/,
        qr/Warning: message .+ delayed\s+/,
        qr/Delivery Status Notification/,
    ],
    'message-id' => qr/\A[<]\w+[-]\w+[-]\w+[@].+\z/,
    # Message-Id: <E1P1YNN-0003AD-Ga@example.org>
};

my $RxComm = [
    # transports/smtp.c:564|  *message = US string_sprintf("SMTP error from remote mail server after %s%s: "
    # transports/smtp.c:837|  string_sprintf("SMTP error from remote mail server after RCPT TO:<%s>: "
    qr/SMTP error from remote (?:mail server|mailer) after ([A-Za-z]{4})/,
    qr/SMTP error from remote (?:mail server|mailer) after end of ([A-Za-z]{4})/,
];

my $RxSess = {
    # find exim/ -type f -exec grep 'message = US' {} /dev/null \;
    'expired' => [
        # retry.c:902|  addr->message = (addr->message == NULL)? US"retry timeout exceeded" :
        qr/retry timeout exceeded/,

        # deliver.c:7475|  "No action is required on your part. Delivery attempts will continue for\n"
        qr/No action is required on your part/,
    ],
    'userunknown' => [
        # route.c:1158|  DEBUG(D_uid) debug_printf("getpwnam() returned NULL (user not found)\n");
        qr/user not found/,
    ],
    'hostunknown' => [
        # routers/dnslookup.c:331|  addr->message = US"all relevant MX records point to non-existent hosts";
        qr/all relevant MX records point to non-existent hosts/,

        # route.c:1826|  uschar *message = US"Unrouteable address";
        qr/Unrouteable address/,

        # transports/smtp.c:3524|  addr->message = US"all host address lookups failed permanently";
        qr/all host address lookups failed permanently/,
    ],
    'mailboxfull' => [
        # transports/appendfile.c:2567|  addr->user_message = US"mailbox is full";
        qr/mailbox is full:?/,

        # transports/appendfile.c:3049|  addr->message = string_sprintf("mailbox is full "$                          
        # transports/appendfile.c:3050|  "(quota exceeded while writing to file %s)", filename);$
        qr/error: quota exceed/,
    ],
    'notaccept' => [
        # routers/dnslookup.c:328|  addr->message = US"an MX or SRV record indicated no SMTP service";
        qr/an MX or SRV record indicated no SMTP service/,

        # transports/smtp.c:3502|  addr->message = US"no host found for existing SMTP connection";
        qr/no host found for existing SMTP connection/,
    ],
    'systemerror' => [
        # deliver.c:5614|  addr->message = US"delivery to file forbidden";
        # deliver.c:5624|  addr->message = US"delivery to pipe forbidden";
        qr/delivery to (?:file|pipe) forbidden/,

        # transports/pipe.c:1156|  addr->user_message = US"local delivery failed";
        qr/local delivery failed/,
    ],
    'contenterror' => [
        # deliver.c:5425|  new->message = US"Too many \"Received\" headers - suspected mail loop";
        qr/Too many ["]Received["] headers /,
    ],
};

sub version     { '4.0.11' }
sub description { 'Exim' }
sub smtpagent   { 'Exim' }
sub headerlist  { return [ 'X-Failed-Recipients' ] }

sub scan {
    # @Description  Detect an error from Exim
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless grep { $mhead->{'subject'} =~ $_ } @{ $RxMTA->{'subject'} };
    return undef unless $mhead->{'from'} =~ $RxMTA->{'from'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $localhost0 = '';    # (String) Local MTA

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

            } elsif( $e =~ m/\A\s+([^\s\t]+[@][^\s\t]+[.][a-zA-Z]+)\z/ ) {
                #   kijitora@example.jp
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( scalar @$dscontents == $recipients ) {
                # Error message
                next unless length $e;
                $v->{'diagnosis'} .= $e.' ';

            } else {
                # Error message when email address above does not include '@'
                # and domain part.
                next unless $e =~ m/\A\s{4}/;
                $v->{'alterrors'} .= $e.' ';
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    unless( $recipients ) {
        # Fallback for getting recipient addresses
        if( defined $mhead->{'x-failed-recipients'} ) {
            # X-Failed-Recipients: kijitora@example.jp
            my $rcptinhead = [ split( ',', $mhead->{'x-failed-recipients'} ) ];
            map { $_ =~ y/ //d } @$rcptinhead;
            $recipients = scalar @$rcptinhead;

            for my $e ( @$rcptinhead ) {
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
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'} ||= __PACKAGE__->smtpagent;
        $e->{'lhost'} ||= $localhost0;

        if( exists $e->{'alterrors'} && length $e->{'alterrors'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $e->{'alterrors'};
            if( $e->{'diagnosis'} =~ m/\A[-]+/ || $e->{'diagnosis'} =~ m/__\z/ ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $e->{'alterrors'} if length $e->{'alterrors'};
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
            SMTP: for my $r ( @$RxComm ) {
                # Verify each regular expression of SMTP commands
                next unless $e->{'diagnosis'} =~ $r;
                $e->{'command'} = uc $1;
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
                        PATTERN: for my $rr ( @{ $RxSess->{ $r } } ) {
                            # Check each regular expression
                            next unless $e->{'diagnosis'} =~ $rr;
                            $e->{'reason'} = $r;
                            last(SESSION);
                        }
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

Sisimai::MTA::Exim - bounce mail parser class for Exim.

=head1 SYNOPSIS

    use Sisimai::MTA::Exim;

=head1 DESCRIPTION

Sisimai::MTA::Exim parses a bounce email which created by Exim.  Methods in the
module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Exim->version;

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

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
