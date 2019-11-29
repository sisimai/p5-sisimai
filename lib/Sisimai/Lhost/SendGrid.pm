package Sisimai::Lhost::SendGrid;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['This is an automatically generated message from SendGrid.'],
    'rfc822'  => ['Content-Type: message/rfc822'],
};

# Return-Path: <apps@sendgrid.net>
# X-Mailer: MIME-tools 5.502 (Entity 5.502)
sub headerlist  { return ['return-path', 'x-mailer'] }
sub description { 'SendGrid: https://sendgrid.com/' }
sub make {
    # Detect an error from SendGrid
    # @param         [Hash] mhead       Message headers of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.0.2
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    # 'from'        => qr/\AMAILER-DAEMON\z/,
    return undef unless $mhead->{'return-path'};
    return undef unless $mhead->{'return-path'} eq '<apps@sendgrid.net>';
    return undef unless $mhead->{'subject'} eq 'Undelivered Mail Returned to Sender';

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $v = undef;
    my $p = '';

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            if( $e eq $StartingOf->{'message'}->[0] ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part(message/rfc822)
            if( index($e, $StartingOf->{'rfc822'}->[0]) == 0 ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # message/rfc822 OR text/rfc822-headers part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # message/delivery-status part
            next unless $readcursor & $Indicators->{'deliverystatus'};
            next unless length $e;

            if( my $f = Sisimai::RFC1894->match($e) ) {
                # $e matched with any field defined in RFC3464
                my $o = Sisimai::RFC1894->field($e);
                $v = $dscontents->[-1];

                unless( $o ) {
                    # Fallback code for empty value or invalid formatted value
                    # - Status: (empty)
                    # - Diagnostic-Code: 550 5.1.1 ... (No "diagnostic-type" sub field)
                    $v->{'diagnosis'} = $1 if $e =~ /\ADiagnostic-Code:[ ]*(.+)/;
                    next;
                }

                if( $o->[-1] eq 'addr' ) {
                    # Final-Recipient: rfc822; kijitora@example.jp
                    # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                    if( $o->[0] eq 'final-recipient' ) {
                        # Final-Recipient: rfc822; kijitora@example.jp
                        if( $v->{'recipient'} ) {
                            # There are multiple recipient addresses in the message body.
                            push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                            $v = $dscontents->[-1];
                        }
                        $v->{'recipient'} = $o->[2];
                        $recipients++;

                    } else {
                        # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                        $v->{'alias'} = $o->[2];
                    }
                } elsif( $o->[-1] eq 'code' ) {
                    # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                    $v->{'spec'} = $o->[1];
                    $v->{'diagnosis'} = $o->[2];

                } elsif( $o->[-1] eq 'date' ) {
                    # Arrival-Date: 2012-12-31 23-59-59
                    next unless $e =~ /\AArrival-Date: (\d{4})[-](\d{2})[-](\d{2}) (\d{2})[-](\d{2})[-](\d{2})\z/;
                    $o->[1] .= 'Thu, '.$3.' ';
                    $o->[1] .= Sisimai::DateTime->monthname(0)->[int($2) - 1];
                    $o->[1] .= ' '.$1.' '.join(':', $4, $5, $6);
                    $o->[1] .= ' '.Sisimai::DateTime->abbr2tz('CDT');
                } else {
                    # Other DSN fields defined in RFC3464
                    next unless exists $fieldtable->{ $o->[0] };
                    $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                    next unless $f == 1;
                    $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
                }
            } else {
                # This is an automatically generated message from SendGrid.
                #
                # I'm sorry to have to tell you that your message was not able to be
                # delivered to one of its intended recipients.
                #
                # If you require assistance with this, please contact SendGrid support.
                #
                # shironekochan:000000:<kijitora@example.jp> : 192.0.2.250 : mx.example.jp:[192.0.2.153] :
                #   550 5.1.1 <userunknown@cubicroot.jp>... User Unknown  in RCPT TO
                #
                # ------------=_1351676802-30315-116783
                # Content-Type: message/delivery-status
                # Content-Disposition: inline
                # Content-Transfer-Encoding: 7bit
                # Content-Description: Delivery Report
                #
                # X-SendGrid-QueueID: 959479146
                # X-SendGrid-Sender: <bounces+61689-10be-kijitora=example.jp@sendgrid.info>
                if( $e =~ /.+ in (?:End of )?([A-Z]{4}).*\z/ ) {
                    # in RCPT TO, in MAIL FROM, end of DATA
                    $commandtxt = $1;

                } else {
                    # Continued line of the value of Diagnostic-Code field
                    next unless index($p, 'Diagnostic-Code:') == 0;
                    next unless $e =~ /\A[ \t]+(.+)\z/;
                    $v->{'diagnosis'} .= ' '.$1;
                }
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Get the value of SMTP status code as a pseudo D.S.N.
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'status'} = $1.'.0.0' if $e->{'diagnosis'} =~ /\b([45])\d\d[ \t]*/;

        if( $e->{'status'} eq '5.0.0' || $e->{'status'} eq '4.0.0' ) {
            # Get the value of D.S.N. from the error message or the value of
            # Diagnostic-Code header.
            $e->{'status'} = Sisimai::SMTP::Status->find($e->{'diagnosis'}) || $e->{'status'};
        }

        if( $e->{'action'} eq 'expired' ) {
            # Action: expired
            $e->{'reason'} = 'expired';
            if( ! $e->{'status'} || substr($e->{'status'}, -4, 4) eq '.0.0' ) {
                # Set pseudo Status code value if the value of Status is not
                # defined or 4.0.0 or 5.0.0.
                $e->{'status'} = Sisimai::SMTP::Status->code('expired') || $e->{'status'};
            }
        }
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'lhost'}   ||= $permessage->{'rhost'};
        $e->{'command'} ||= $commandtxt;
    }
    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

sub json {
    # Adapt SendGrid bounce object for Sisimai::Message format
    # @param        [Hash] argvs     bounce object(JSON) retrieved via SendGrid API
    # @return       [Hash, Undef]    Bounce data list and message/rfc822 part
    #                                or Undef if it failed to parse or the
    #                                arguments are missing
    # @since v4.20.0
    # @until v4.25.5
    my $class = shift;
    my $argvs = shift;

    return undef unless ref $argvs eq 'HASH';
    return undef unless scalar keys %$argvs;
    return undef unless exists $argvs->{'email'};
    return undef unless Sisimai::RFC5322->is_emailaddress($argvs->{'email'});

    my $dscontents = undef;
    my $rfc822head = {};
    my $v = undef;

    if( exists $argvs->{'event'} ) {
        # https://sendgrid.com/docs/API_Reference/Webhooks/event.html
        # {
        #   'tls' => 0,
        #   'timestamp' => 1504555832,
        #   'event' => 'bounce',
        #   'email' => 'mailboxfull@example.jp',
        #   'ip' => '192.0.2.22',
        #   'sg_message_id' => '03_Wof6nRbqqzxRvLpZbfw.filter0017p3mdw1-11399-59ADB335-16.0',
        #   'type' => 'blocked',
        #   'sg_event_id' => 'S4wr46YHS0qr3BKhawTQjQ',
        #   'reason' => '550 5.2.2 <mailboxfull@example.jp>... Mailbox Full ',
        #   'smtp-id' => '<201709042010.v84KAQ5T032530@example.nyaan.jp>',
        #   'status' => '5.2.2'
        # },
        return undef unless $argvs->{'event'} =~ /\A(?:bounce|deferred|delivered|spamreport)\z/;
        use Sisimai::Time;
        $dscontents = [__PACKAGE__->DELIVERYSTATUS];
        $v = $dscontents->[-1];

        $v->{'date'}      = gmtime(Sisimai::Time->new($argvs->{'timestamp'}));
        $v->{'agent'}     = __PACKAGE__->smtpagent;
        $v->{'lhost'}     = $argvs->{'ip'};
        $v->{'status'}    = $argvs->{'status'} || '';
        $v->{'diagnosis'} = Sisimai::String->sweep($argvs->{'reason'} || $argvs->{'response'}) || '';
        $v->{'recipient'} = $argvs->{'email'};

        if( $argvs->{'event'} eq 'delivered' ) {
            # "event": "delivered"
            $v->{'reason'} = 'delivered';

        } elsif( $argvs->{'event'} eq 'spamreport' ) {
            # [
            #   {
            #     "email": "kijitora@example.com",
            #     "timestamp": 1504837383,
            #     "sg_message_id": "6_hrAeKvTDaB5ynBI2nbnQ.filter0002p3las1-27574-59B1FDA3-19.0",
            #     "sg_event_id": "o70uHqbMSXOaaoveMZIjjg",
            #     "event": "spamreport"
            #   }
            # ]
            $v->{'reason'} = 'feedback';
            $v->{'feedbacktype'} = 'abuse';
        }
        $v->{'status'}    ||= Sisimai::SMTP::Status->find($v->{'diagnosis'}) || '';
        $v->{'replycode'} ||= Sisimai::SMTP::Reply->find($v->{'diagnosis'})  || '';

        # Generate pseudo message/rfc822 part
        $rfc822head = {
            'from'       => Sisimai::Address->undisclosed('s'),
            'message-id' => $argvs->{'sg_message_id'},
        };
    } else {
        #   {
        #       "status": "4.0.0",
        #       "created": "2011-09-16 22:02:19",
        #       "reason": "Unable to resolve MX host sendgrid.ne",
        #       "email": "esting@sendgrid.ne"
        #   },
        $dscontents = [__PACKAGE__->DELIVERYSTATUS];
        $v = $dscontents->[-1];

        $v->{'recipient'} = $argvs->{'email'};
        $v->{'date'} = $argvs->{'created'};

        my $statuscode = $argvs->{'status'} || '';
        my $diagnostic = Sisimai::String->sweep($argvs->{'reason'}) || '';

        if( $statuscode =~ /\A[245]\d\d\z/ ) {
            # "status": "550"
            $v->{'replycode'} = $statuscode;

        } elsif( $statuscode =~ /\A[245][.]\d[.]\d+\z/ ) {
            # "status": "5.1.1"
            $v->{'status'} = $statuscode;
        }

        $v->{'status'}    ||= Sisimai::SMTP::Status->find($diagnostic) || '';
        $v->{'replycode'} ||= Sisimai::SMTP::Reply->find($diagnostic)  || '';
        $v->{'diagnosis'}   = $argvs->{'reason'} || '';
        $v->{'agent'}       = __PACKAGE__->smtpagent;

        # Generate pseudo message/rfc822 part
        $rfc822head = {
            'from' => Sisimai::Address->undisclosed('s'),
            'date' => $v->{'date'},
        };
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822head };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::SendGrid - bounce mail parser class for C<SendGrid>.

=head1 SYNOPSIS

    use Sisimai::Lhost::SendGrid;

=head1 DESCRIPTION

Sisimai::Lhost::SendGrid parses a bounce email which created by C<SendGrid>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::SendGrid->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::SendGrid->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head2 C<B<json(I<Hash>)>>

C<json()> method adapts SendGrid bounce object (JSON) for Perl hash object
used at Sisimai::Message class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
