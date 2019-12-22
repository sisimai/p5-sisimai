package Sisimai::Lhost::MailMarshalSMTP;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = {
    'message'  => ['Your message:'],
    'error'    => ['Could not be delivered because of'],
    'rcpts'    => ['The following recipients were affected:'],
};
my $MarkingsOf = { 'rfc822' => undef };

sub description { 'Trustwave Secure Email Gateway' }
sub make {
    # Detect an error from MailMarshalSMTP
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
    # @since v4.1.9
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    return undef unless index($mhead->{'subject'}, 'Undeliverable Mail: "') == 0;

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $endoferror = 0;     # (Integer) Flag for the end of error message
    my $v = undef;

    if( my $boundary00 = Sisimai::MIME->boundary($mhead->{'content-type'}) ) {
        # Convert to regular expression
        $boundary00 = '--'.$boundary00.'--';
        $MarkingsOf->{'rfc822'} = qr/\A\Q$boundary00\E\z/;

    } else {
        $MarkingsOf->{'rfc822'} = qr/\A[ \t]*[+]+[ \t]*\z/;
    }

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor |= $Indicators->{'deliverystatus'} if $e eq $StartingOf->{'message'}->[0];
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor |= $Indicators->{'message-rfc822'} if $e =~ $MarkingsOf->{'rfc822'};
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Inside of the original message part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # Error message part
            next unless $readcursor & $Indicators->{'deliverystatus'};
            last if $e =~ $MarkingsOf->{'rfc822'};

            # Your message:
            #    From:    originalsender@example.com
            #    Subject: ...
            #
            # Could not be delivered because of
            #
            # 550 5.1.1 User unknown
            #
            # The following recipients were affected:
            #    dummyuser@blabla.xxxxxxxxxxxx.com
            $v = $dscontents->[-1];

            if( $e =~ /\A[ \t]{4}([^ ]+[@][^ ]+)\z/ ) {
                # The following recipients were affected:
                #    dummyuser@blabla.xxxxxxxxxxxx.com
                if( $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[-1];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } else {
                # Get error message lines
                if( $e eq $StartingOf->{'error'}->[0] ) {
                    # Could not be delivered because of
                    #
                    # 550 5.1.1 User unknown
                    $v->{'diagnosis'} = $e;

                } elsif( $v->{'diagnosis'} && ! $endoferror ) {
                    # Append error messages
                    $endoferror = 1 if index($e, $StartingOf->{'rcpts'}->[0]) == 0;
                    next if $endoferror;

                    $v->{'diagnosis'} .= ' '.$e;

                } else {
                    # Additional Information
                    # ======================
                    # Original Sender:    <originalsender@example.com>
                    # Sender-MTA:         <10.11.12.13>
                    # Remote-MTA:         <10.0.0.1>
                    # Reporting-MTA:      <relay.xxxxxxxxxxxx.com>
                    # MessageName:        <B549996730000.000000000001.0003.mml>
                    # Last-Attempt-Date:  <16:21:07 seg, 22 Dezembro 2014>
                    if( $e =~ /\AOriginal Sender:[ \t]+[<](.+)[>]\z/ ) {
                        # Original Sender:    <originalsender@example.com>
                        # Use this line instead of "From" header of the original
                        # message.
                        push @$rfc822list, 'From: '.$1;

                    } elsif( $e =~ /\ASender-MTA:[ \t]+[<](.+)[>]\z/ ) {
                        # Sender-MTA:         <10.11.12.13>
                        $v->{'lhost'} = $1;

                    } elsif( $e =~ /\AReporting-MTA:[ \t]+[<](.+)[>]\z/ ) {
                        # Reporting-MTA:      <relay.xxxxxxxxxxxx.com>
                        $v->{'rhost'} = $1;

                    } elsif( $e =~ /\A\s+(From|Subject):\s*(.+)\z/ ) {
                        #    From:    originalsender@example.com
                        #    Subject: ...
                        push @$rfc822list, sprintf("%s: %s", $1, $2);
                    }
                }
            }
        } # End of error message part
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'agent'}     = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => ${ Sisimai::RFC5322->weedout($rfc822list) } };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::MailMarshalSMTP - bounce mail parser class for
C<Trustwave Secure Email Gateway>.

=head1 SYNOPSIS

    use Sisimai::Lhost::MailMarshalSMTP;

=head1 DESCRIPTION

Sisimai::Lhost::MailMarshalSMTP parses a bounce email which created by
C<Trustwave Secure Email Gateway>: formerly MailMarshal SMTP.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::MailMarshalSMTP->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::MailMarshalSMTP->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut


