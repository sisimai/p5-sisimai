package Sisimai::Lhost::AmazonSES;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

# http://aws.amazon.com/ses/
my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message' => ['The following message to <', 'An error occurred while trying to deliver the mail '],
    'rfc822'  => ['content-type: message/rfc822'],
};
my $MessagesOf = { 'expired' => ['Delivery expired'] };

# X-SenderID: Sendmail Sender-ID Filter v1.0.0 nijo.example.jp p7V3i843003008
# X-Original-To: 000001321defbd2a-788e31c8-2be1-422f-a8d4-cf7765cc9ed7-000000@email-bounces.amazonses.com
# X-AWS-Outgoing: 199.255.192.156
# X-SES-Outgoing: 2016.10.12-54.240.27.6
sub headerlist  { ['x-aws-outgoing', 'x-ses-outgoing', 'x-amz-sns-message-id'] }
sub description { 'Amazon SES(Sending): http://aws.amazon.com/ses/' };
sub make {
    # Detect an error from Amazon SES
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

    if( index($$mbody, '{') == 0 ) {
        # The message body is JSON string
        return undef unless exists $mhead->{'x-amz-sns-message-id'};
        return undef unless $mhead->{'x-amz-sns-message-id'};

        my $jsonstring = '';
        my $foldedline = 0;
        my $sespayload = undef;

        for my $e ( split(/\n/, $$mbody) ) {
            # Find JSON string from the message body
            next unless length $e;
            last if $e eq '--';
            last if $e eq '__END_OF_EMAIL_MESSAGE__';

            substr($e, 0, 1, '') if $foldedline; # The line starts with " ", continued from !\n.
            $foldedline = 0;

            if( substr($e, -1, 1) eq '!' ) {
                # ... long long line ...![\n]
                substr($e, -1, 1, '');
                $foldedline = 1;
            }
            $jsonstring .= $e;
        }

        require JSON;
        eval {
            my $jsonparser = JSON->new;
            my $jsonobject = $jsonparser->decode($jsonstring);

            if( exists $jsonobject->{'Message'} ) {
                # 'Message' => '{"notificationType":"Bounce",...
                $sespayload = $jsonparser->decode($jsonobject->{'Message'});

            } else {
                # 'mail' => { 'sourceArn' => '...',... }, 'bounce' => {...},
                $sespayload = $jsonobject;
            }
        };
        if( $@ ) {
            # Something wrong in decoding JSON
            warn sprintf(" ***warning: Failed to decode JSON: %s", $@);
            return undef;
        }
        return __PACKAGE__->json($sespayload);

    } else {
        # The message body is an email
        # 'from'    => qr/\AMAILER-DAEMON[@]email[-]bounces[.]amazonses[.]com\z/,
        # 'subject' => qr/\ADelivery Status Notification [(]Failure[)]\z/,
        my $match = 0;
        my $xmail = $mhead->{'x-mailer'} || '';

        return undef if index($xmail, 'Amazon WorkMail') > -1;
        $match ||= 1 if $mhead->{'x-aws-outgoing'};
        $match ||= 1 if $mhead->{'x-ses-outgoing'};
        return undef unless $match;

        require Sisimai::RFC1894;
        my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
        my $permessage = {};    # (Hash) Store values of each Per-Message field

        my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
        my $rfc822part = '';    # (String) message/rfc822-headers part
        my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
        my $blanklines = 0;     # (Integer) The number of blank lines
        my $readcursor = 0;     # (Integer) Points the current cursor position
        my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
        my $v = undef;
        my $p = '';

        for my $e ( split("\n", $$mbody) ) {
            # Read each line between the start of the message and the start of rfc822 part.
            unless( $readcursor ) {
                # Beginning of the bounce message or message/delivery-status part
                if( index($e, $StartingOf->{'message'}->[0]) == 0 ||
                    index($e, $StartingOf->{'message'}->[1]) == 0 ) {
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
                # message/rfc822 or text/rfc822-headers part
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
                    next unless my $o = Sisimai::RFC1894->field($e);
                    $v = $dscontents->[-1];

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

                    } else {
                        # Other DSN fields defined in RFC3464
                        next unless exists $fieldtable->{ $o->[0] };
                        $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                        next unless $f == 1;
                        $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
                    }
                } else {
                    # Continued line of the value of Diagnostic-Code field
                    next unless index($p, 'Diagnostic-Code:') == 0;
                    next unless $e =~ /\A[ \t]+(.+)\z/;
                    $v->{'diagnosis'} .= ' '.$1;
                }
            } # End of message/delivery-status
        } continue {
            # Save the current line for the next loop
            $p = $e;
        }
        return undef unless $recipients;

        for my $e ( @$dscontents ) {
            # Set default values if each value is empty.
            $e->{'lhost'} ||= $permessage->{'rhost'};
            map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;

            $e->{'agent'}     = __PACKAGE__->smtpagent;
            $e->{'diagnosis'} =~ y/\n/ /;
            $e->{'diagnosis'} =  Sisimai::String->sweep($e->{'diagnosis'});

            if( $e->{'status'} =~ /\A[45][.][01][.]0\z/ ) {
                # Get other D.S.N. value from the error message
                # 5.1.0 - Unknown address error 550-'5.7.1 ...
                my $errormessage = $e->{'diagnosis'};
                   $errormessage = $1 if $e->{'diagnosis'} =~ /["'](\d[.]\d[.]\d.+)['"]/;
                $e->{'status'}   = Sisimai::SMTP::Status->find($errormessage) || $e->{'status'};
            }

            SESSION: for my $r ( keys %$MessagesOf ) {
                # Verify each regular expression of session errors
                next unless grep { index($e->{'diagnosis'}, $_) > -1 } @{ $MessagesOf->{ $r } };
                $e->{'reason'} = $r;
                last;
            }
        }
        $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
        return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
    }
}

sub json {
    # Adapt Amazon SES bounce object for Sisimai::Message format
    # @param        [Hash] argvs     bounce object(JSON) retrieved from Amazon SNS
    # @return       [Hash, Undef]    Bounce data list and message/rfc822 part
    #                                or Undef if it failed to parse or the
    #                                arguments are missing
    # @since v4.20.0
    my $class = shift;
    my $argvs = shift;

    return undef unless ref $argvs eq 'HASH';
    return undef unless keys %$argvs;
    return undef unless exists $argvs->{'notificationType'};
    use Sisimai::RFC5322;

    # https://docs.aws.amazon.com/en_us/ses/latest/DeveloperGuide/notification-contents.html
    my $bouncetype = {
        'Permanent' => {
            'General'    => '',
            'NoEmail'    => '',
            'Suppressed' => '',
        },
        'Transient' => {
            'General'            => '',
            'MailboxFull'        => 'mailboxfull',
            'MessageTooLarge'    => 'mesgtoobig',
            'ContentRejected'    => '',
            'AttachmentRejected' => '',
        },
    };

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822head = {};    # (Hash) Check flags for headers in RFC822 part
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $labeltable = {
        'Bounce'    => 'bouncedRecipients',
        'Complaint' => 'complainedRecipients',
    };
    my $v = undef;

    if( $argvs->{'notificationType'} eq 'Bounce' || $argvs->{'notificationType'} eq 'Complaint' ) {
        # { "notificationType":"Bounce", "bounce": { "bounceType":"Permanent",...
        my $o = $argvs->{ lc $argvs->{'notificationType'} };
        my $r = $o->{ $labeltable->{ $argvs->{'notificationType'} } } || [];

        for my $e ( @$r ) {
            # 'bouncedRecipients' => [ { 'emailAddress' => 'bounce@si...' }, ... ]
            # 'complainedRecipients' => [ { 'emailAddress' => 'complaint@si...' }, ... ]
            next unless Sisimai::RFC5322->is_emailaddress($e->{'emailAddress'});

            $v = $dscontents->[-1];
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $recipients++;
            $v->{'recipient'} = $e->{'emailAddress'};

            if( $argvs->{'notificationType'} eq 'Bounce' ) {
                # 'bouncedRecipients => [ {
                #   'emailAddress' => 'bounce@simulator.amazonses.com',
                #   'action' => 'failed',
                #   'status' => '5.1.1',
                #   'diagnosticCode' => 'smtp; 550 5.1.1 user unknown'
                # }, ... ]
                $v->{'action'} = $e->{'action'};
                $v->{'status'} = $e->{'status'};

                if( $e->{'diagnosticCode'} =~ /\A(.+?);[ ]*(.+)\z/ ) {
                    # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                    $v->{'spec'} = uc $1;
                    $v->{'diagnosis'} = $2;

                } else {
                    $v->{'diagnosis'} = $e->{'diagnosticCode'};
                }

                # 'reportingMTA' => 'dsn; a27-23.smtp-out.us-west-2.amazonses.com',
                $v->{'lhost'} = $1 if $o->{'reportingMTA'} =~ /\Adsn;[ ](.+)\z/;

                if( exists $bouncetype->{ $o->{'bounceType'} } &&
                    exists $bouncetype->{ $o->{'bounceType'} }->{ $o->{'bounceSubType'} } ) {
                    # 'bounce' => {
                    #       'bounceType' => 'Permanent',
                    #       'bounceSubType' => 'General'
                    # },
                    $v->{'reason'} = $bouncetype->{ $o->{'bounceType'} }->{ $o->{'bounceSubType'} };
                }
            } else {
                # 'complainedRecipients' => [ {
                #   'emailAddress' => 'complaint@simulator.amazonses.com' }, ... ],
                $v->{'reason'} = 'feedback';
                $v->{'feedbacktype'} = $o->{'complaintFeedbackType'} || '';
            }
            ($v->{'date'} = $o->{'timestamp'} || $argvs->{'mail'}->{'timestamp'}) =~ s/[.]\d+Z\z//;
        }
    } elsif( $argvs->{'notificationType'} eq 'Delivery' ) {
        # { "notificationType":"Delivery", "delivery": { ...
        my $o = $argvs->{'delivery'};
        my $r = $o->{'recipients'} || [];

        for my $e ( @$r ) {
            # 'delivery' => {
            #       'timestamp' => '2016-11-23T12:01:03.512Z',
            #       'processingTimeMillis' => 3982,
            #       'reportingMTA' => 'a27-29.smtp-out.us-west-2.amazonses.com',
            #       'recipients' => [
            #           'success@simulator.amazonses.com'
            #       ],
            #       'smtpResponse' => '250 2.6.0 Message received'
            #   },
            next unless Sisimai::RFC5322->is_emailaddress($e);

            $v = $dscontents->[-1];
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $recipients++;
            $v->{'recipient'} = $e;
            $v->{'lhost'}     = $o->{'reportingMTA'} || '';
            $v->{'diagnosis'} = $o->{'smtpResponse'} || '';
            $v->{'status'}    = Sisimai::SMTP::Status->find($v->{'diagnosis'}) || '';
            $v->{'replycode'} = Sisimai::SMTP::Reply->find($v->{'diagnosis'})  || '';
            $v->{'reason'}    = 'delivered';
            $v->{'action'}    = 'deliverable';
            ($v->{'date'} = $o->{'timestamp'} || $argvs->{'mail'}->{'timestamp'}) =~ s/[.]\d+Z\z//;
        }
    } else {
        # The value of "notificationType" is not any of "Bounce", "Complaint",
        # or "Delivery".
        return undef;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'agent'} = __PACKAGE__->smtpagent;
    }

    if( exists $argvs->{'mail'}->{'headers'} ) {
        # "headersTruncated":false,
        # "headers":[ { ...
        for my $e ( @{ $argvs->{'mail'}->{'headers'} } ) {
            # 'headers' => [ { 'name' => 'From', 'value' => 'neko@nyaan.jp' }, ... ],
            next unless $e->{'name'} =~ /\A(?:From|To|Subject|Message-ID|Date)\z/;
            $rfc822head->{ lc $e->{'name'} } = $e->{'value'};
        }
    }

    unless( $rfc822head->{'message-id'} ) {
        # Try to get the value of "Message-Id".
        # 'messageId' => '01010157e48f9b9b-891e9a0e-9c9d-4773-9bfe-608f2ef4756d-000000'
        $rfc822head->{'message-id'} = $argvs->{'mail'}->{'messageId'} if $argvs->{'mail'}->{'messageId'};
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822head };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::AmazonSES - bounce mail parser class for C<Amazon SES>.

=head1 SYNOPSIS

    use Sisimai::Lhost::AmazonSES;

=head1 DESCRIPTION

Sisimai::Lhost::AmazonSES parses a bounce email or a JSON string which created
by C<Amazon Simple Email Service>. Methods in the module are called from only
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::AmazonSES->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::AmazonSES->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head2 C<B<json(I<Hash>)>>

C<json()> method adapts Amazon SES bounce object (JSON) for Perl hash object
used at Sisimai::Message class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
