package Sisimai::MSP::RU::MailRu;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# Based on Sisimai::MTA::Exim
my $RxMSP = {
    'from'      => qr/\Amailer-daemon[@].*mail[.]ru/,
    'rfc822'    => qr/\A------ This is a copy of the message.+headers[.] ------\z/,
    'begin'     => qr/\AThis message was created automatically by mail delivery software[.]/,
    'endof'     => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'   => qr/Mail failure[.]\z/,
    'message-id'=> qr/\A[<]\w+[-]\w+[-]\w+[@].*mail[.]ru[>]\z/,
    # Message-Id: <E1P1YNN-0003AD-Ga@*.mail.ru>
};

my $RxComm = [
    qr/SMTP error from remote (?:mail server|mailer) after ([A-Za-z]{4})/,
    qr/SMTP error from remote (?:mail server|mailer) after end of ([A-Za-z]{4})/,
];

my $RxSess = {
    'expired' => [
        qr/retry timeout exceeded/,
        qr/No action is required on your part/,
    ],
    'userunknown' => [
        qr/user not found/,
    ],
    'hostunknown' => [
        qr/all relevant MX records point to non-existent hosts/,
        qr/Unrouteable address/,
        qr/all host address lookups failed permanently/,
    ],
    'mailboxfull' => [
        qr/mailbox is full:?/,
        qr/error: quota exceed/,
    ],
    'notaccept' => [
        qr/an MX or SRV record indicated no SMTP service/,
        qr/no host found for existing SMTP connection/,
    ],
    'systemerror' => [
        qr/delivery to (?:file|pipe) forbidden/,
        qr/local delivery failed/,
    ],
    'contenterror' => [
        qr/Too many ["]Received["] headers /,
    ],
};

sub version     { '4.0.0' }
sub description { '@mail.ru' }
sub smtpagent   { 'RU::MailRu' }
sub headerlist  { return [ 'X-Failed-Recipients' ] }

sub scan {
    # @Description  Detect an error from @mail.ru
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'}    =~ $RxMSP->{'subject'};
    return undef unless $mhead->{'from'}       =~ $RxMSP->{'from'};
    return undef unless $mhead->{'message-id'} =~ $RxMSP->{'message-id'};

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
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
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

            # Это письмо создано автоматически
            # сервером Mail.Ru, # отвечать на него не
            # нужно.
            #
            # К сожалению, Ваше письмо не может
            # быть# доставлено одному или нескольким
            # получателям:
            #
            # **********************
            #
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
                # recipients. This is a permanent error. The following address(es) failed:
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

Sisimai::MSP::RU::MailRu - bounce mail parser class for C<@mail.ru>.

=head1 SYNOPSIS

    use Sisimai::MSP::RU::MailRu;

=head1 DESCRIPTION

Sisimai::MSP::RU::MailRu parses a bounce email which created by C<@mail.ru>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::RU::MailRu->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::RU::MailRu->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::RU::MailRu->smtpagent;

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
