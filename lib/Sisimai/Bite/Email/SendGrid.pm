package Sisimai::Bite::Email::SendGrid;
use parent 'Sisimai::Bite::Email';
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
sub headerlist  { return ['Return-Path', 'X-Mailer'] }
sub description { 'SendGrid: http://sendgrid.com/' }
sub scan {
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
    my $fieldindex = Sisimai::RFC1894->FIELDINDEX;
    my $mesgfields = Sisimai::RFC1894->FIELDINDEX('mesg');
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my @hasdivided = split("\n", $$mbody);
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $v = undef;
    my $p = '';
    my $o = [];

    for my $e ( @hasdivided ) {
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

            if( grep { index($e, $_) == 0 } @$fieldindex ) {
                # $e matched with any field defined in RFC3464
                $o = Sisimai::RFC1894->field($e);
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
                    if( $e =~ /\AArrival-Date: (\d{4})[-](\d{2})[-](\d{2}) (\d{2})[-](\d{2})[-](\d{2})\z/ ) {
                        # Arrival-Date: 2011-08-12 01-05-05
                        $o->[1] .= 'Thu, '.$3.' ';
                        $o->[1] .= Sisimai::DateTime->monthname(0)->[int($2) - 1];
                        $o->[1] .= ' '.$1.' '.join(':', $4, $5, $6);
                        $o->[1] .= ' '.Sisimai::DateTime->abbr2tz('CDT');
                    }

                } else {
                    # Other DSN fields defined in RFC3464
                    next unless exists $fieldtable->{ $o->[0] };
                    $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                    next unless grep { index($e, $_) == 0 } @$mesgfields;
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
                    if( index($p, 'Diagnostic-Code:') == 0 && $e =~ /\A[ \t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code field
                        $v->{'diagnosis'} .= ' '.$1;
                    }
                }
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        # Get the value of SMTP status code as a pseudo D.S.N.
        $e->{'status'} = $1.'.0.0' if $e->{'diagnosis'} =~ /\b([45])\d\d[ \t]*/;

        if( $e->{'status'} eq '5.0.0' || $e->{'status'} eq '4.0.0' ) {
            # Get the value of D.S.N. from the error message or the value of
            # Diagnostic-Code header.
            my $pseudostatus = Sisimai::SMTP::Status->find($e->{'diagnosis'});
            $e->{'status'} = $pseudostatus if $pseudostatus;
        }

        if( $e->{'action'} eq 'expired' ) {
            # Action: expired
            $e->{'reason'} = 'expired';
            if( ! $e->{'status'} || substr($e->{'status'}, -4, 4) eq '.0.0' ) {
                # Set pseudo Status code value if the value of Status is not
                # defined or 4.0.0 or 5.0.0.
                my $pseudostatus = Sisimai::SMTP::Status->code('expired');
                $e->{'status'} = $pseudostatus if $pseudostatus;
            }
        }
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'lhost'}   ||= $permessage->{'rhost'};
        $e->{'command'} ||= $commandtxt;
    }
    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::Email::SendGrid - bounce mail parser class for C<SendGrid>.

=head1 SYNOPSIS

    use Sisimai::Bite::Email::SendGrid;

=head1 DESCRIPTION

Sisimai::Bite::Email::SendGrid parses a bounce email which created by C<SendGrid>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Bite::Email::SendGrid->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Bite::Email::SendGrid->smtpagent;

=head2 C<B<scan(I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2018 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
