package Sisimai::MTA;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC5322;

sub EOM {
    # End of email message as a sentinel for parsing bounce messages
    # @return   [String] Fixed length string like a constant
    # @private
    # @deprecated
    require Sisimai::String;
    warn sprintf(" ***warning: Obsoleted method, use Sisimai::String->EOM() instead.");
    return Sisimai::String->EOM;
}
sub SMTPCOMMAND {
    # Detector for SMTP commands in a bounce mail message
    # @return   [Hash] SMTP command regular expressions
    # @private
    # @deprecated
    require Sisimai::SMTP;
    warn sprintf(" ***warning: Obsoleted method, use Sisimai::SMTP->command() instead.");
    return Sisimai::SMTP->command;
}

sub LONGFIELDS {
    # Fields that might be long
    # @return   [Hash] Long filed(email header) list
    # @private
    # @deprecated
    warn sprintf(" ***warning: Obsoleted method, use Sisimai::RFC5322->LONGFIELDS() instead.");
    return Sisimai::RFC5322->LONGFIELDS;
}

sub RFC822HEADERS { 
    # Grouped RFC822 headers
    # @param    [String] group  RFC822 Header group name
    # @return   [Array,Hash]    RFC822 Header list
    # @private
    # @deprecated
    warn sprintf(" ***warning: Obsoleted method, use Sisimai::RFC5322->HEADERFIELDS() instead.");
    my $class = shift;
    my $group = shift // return [ keys %{ Sisimai::RFC5322->HEADERFIELDS } ];
    return Sisimai::RFC5322->HEADERFIELDS( $group );
}

sub INDICATORS {
    # Flags for position variable for
    # @private
    # @return   [Hash] Position flag data
    # @since    v4.13.0
    return {
        'deliverystatus' => ( 1 << 1 ),
        'message-rfc822' => ( 1 << 2 ),
    };
}

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
        'diagnosis'    => '',   # The value of Diagnostic-Code header
        'recipient'    => '',   # The value of Final-Recipient header
        'softbounce'   => '',   # Soft bounce or not
        'feedbacktype' => '',   # Feedback Type
    };
}

sub index {
    # MTA list
    # @return   [Array] MTA list with order
    my $class = shift;
    my $index = [
        'Sendmail', 'Postfix', 'qmail', 'Exim', 'Courier', 'OpenSMTPD', 
        'Exchange', 'MessagingServer', 'Domino', 'Notes', 'ApacheJames', 
        'McAfee', 'MXLogic', 'MailFoundry', 'IMailServer', 'mFILTER', 
        'Activehunter', 'InterScanMSS', 'SurfControl', 'MailMarshalSMTP',
        'X1', 'X2', 'X3', 'X4', 'X5', 'V5sendmail', 
    ];
    return $index;
}

sub smtpagent {
    # @abstract Return MTA name: Call smtpagent() in each child class
    # @return   [String] MTA name
    my $class = shift; 
    return shift // 'null';
}

sub description {
    # @abstract Description of MTA
    # @return   [String] Description of MTA module
    return '';
}

sub headerlist {
    # @abstract Header list required by each MTA module
    # @return   [Array] Header list
    return [];
}

sub pattern { 
    # @abstract Patterns for detecting MTA
    # @return   [Hash] Pattern table
    return {};
}

sub scan {
    # @abstract      Detect an error
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
    return '';
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA - Base class for Sisimai::MTA::*

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::MTA::*, such as Sisimai::MTA::Sendmail,
instead.

=head1 DESCRIPTION

Sisimai::MTA is a base class for Sisimai::MTA::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
