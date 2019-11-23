package Sisimai::Lhost;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC5322;

sub DELIVERYSTATUS {
    # Data structure for parsed bounce messages
    # @private
    # @return [Hash] Data structure for delivery status
    return {
        'spec'         => '',   # Protocl specification
        'date'         => '',   # The value of Last-Attempt-Date header
        'rhost'        => '',   # The value of Remote-MTA header
        'lhost'        => '',   # The value of Received-From-MTA header
        'alias'        => '',   # The value of alias entry(RHS)
        'agent'        => '',   # MTA name
        'action'       => '',   # The value of Action header
        'status'       => '',   # The value of Status header
        'reason'       => '',   # Temporary reason of bounce
        'command'      => '',   # SMTP command in the message body
        'replycode',   => '',   # SMTP Reply Code
        'diagnosis'    => '',   # The value of Diagnostic-Code header
        'recipient'    => '',   # The value of Final-Recipient header
        'softbounce'   => '',   # Soft bounce or not
        'feedbacktype' => '',   # Feedback Type
    };
}
sub INDICATORS {
    # Flags for position variables
    # @private
    # @return   [Hash] Position flag data
    # @since    v4.13.0
    return {
        'deliverystatus' => (1 << 1),
        'message-rfc822' => (1 << 2),
    };
}
sub removedat   { return 'v4.25.5' }    # This method will be removed at the future release of Sisimai
sub smtpagent   { my $v = shift; $v =~ s/\ASisimai::Lhost::/Email::/; return $v }
sub description { return '' }
sub headerlist  { return [] }
sub index {
    # MTA list
    # @return   [Array] MTA list with order
    return [qw|
        Sendmail Postfix qmail Exim Courier OpenSMTPD Office365 Outlook
        Exchange2007 Exchange2003 Yahoo GSuite Aol SendGrid AmazonSES MailRu
        Yandex MessagingServer Domino Notes ReceivingSES AmazonWorkMail Verizon
        GMX Bigfoot Facebook Zoho EinsUndEins MessageLabs EZweb KDDI Biglobe
        Amavis ApacheJames McAfee MXLogic MailFoundry IMailServer
        mFILTER Activehunter InterScanMSS SurfControl MailMarshalSMTP
        X1 X2 X3 X4 X5 V5sendmail FML Google
    |];
}

sub heads {
    # MTA list which have one or more extra headers
    # @return   [Array] MTA list (have extra headers)
    return [qw|
        Exim Office365 Outlook Exchange2007 Exchange2003 GSuite SendGrid
        AmazonSES ReceivingSES AmazonWorkMail Aol GMX MailRu MessageLabs Yahoo
        Yandex Zoho EinsUndEins MXLogic McAfee mFILTER EZweb Activehunter IMailServer
        SurfControl FML Google
    |];
}

sub make {
    # Method of a parent class to parse a bounce message of each MTA
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
    return undef;
}

sub warn {
    # Print warnings about an obsoleted method
    # This method will be removed at the future release of Sisimai
    # @until v4.25.5
    my $class = shift;
    my $useit = shift || '';
    my $label = ' ***warning:';

    my $calledfrom = [caller(1)];
    my $modulename = $calledfrom->[3]; $modulename =~ s/::[a-zA-Z]+\z//;
    my $methodname = $calledfrom->[3]; $methodname =~ s/\A.+:://;
    my $messageset = sprintf("%s %s->%s is marked as obsoleted", $label, $modulename, $methodname);

    $useit ||= $methodname;
    $messageset .= sprintf(" and will be removed at %s.", __PACKAGE__->removedat);
    $messageset .= sprintf(" Use %s->%s instead.\n", __PACKAGE__, $useit) if $useit ne 'gone';

    warn $messageset;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost - Base class for Sisimai::Lhost::*

=head1 SYNOPSIS

Do not use or require this class directly, use Sisimai::Lhost::*, such as
Sisimai::Lhost::Sendmail, instead.

=head1 DESCRIPTION

Sisimai::Lhost is a base class for all the MTA modules of Sisimai::Lhost::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2017-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

