package Sisimai::MTA;
use feature ':5.10';
use strict;
use warnings;

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

sub SMTPCOMMAND {
    # Detector for SMTP commands in a bounce mail message
    # @private
    # @return   [Hash] SMTP command regular expressions
    return {
        'helo' => qr/\b(?:HELO|EHLO)\b/,
        'mail' => qr/\bMAIL F(?:ROM|rom)\b/,
        'rcpt' => qr/\bRCPT T[Oo]\b/,
        'data' => qr/\bDATA\b/,
    };
}
sub EOM { 
    # End of email message as a sentinel for parsing bounce messages
    # @private
    # @return   [String] Fixed length string like a constant
    return '__END_OF_EMAIL_MESSAGE__';
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
        'feedbacktype' => '',   # FeedBack Type
    };
}

sub LONGFIELDS {
    # Fields that might be long
    # @private
    # @return   [Array] Long filed(email header) list
    return [ 'To', 'From', 'Subject' ];
}

sub RFC822HEADERS {
    # Grouped RFC822 headers
    # @private
    # @param    [String] group  Header group name
    # @return   [Array]         Header list
    my $class = shift;
    my $group = shift // '';
    my $heads = {
        'messageid' => [ 'Message-Id' ],
        'subject'   => [ 'Subject' ],
        'listid'    => [ 'List-Id' ],
        'date'      => [ 'Date', 'Posted-Date', 'Posted', 'Resent-Date', ],
        'addresser' => [ 
            'From', 'Return-Path', 'Reply-To', 'Errors-To', 'Reverse-Path', 
            'X-Postfix-Sender', 'Envelope-From', 'X-Envelope-From',
        ],
        'recipient' => [ 
            'To', 'Delivered-To', 'Forward-Path', 'Envelope-To',
            'X-Envelope-To', 'Resent-To', 'Apparently-To'
        ],
    };

    if( length $group ) {
        # The 1st argument specified
        return $heads->{ $group } if exists $heads->{ $group };

        # Return all the values when the group name does not exist
        return $heads;

    } else {
        # Flatten hash reference then return array reference
        my $lists = [];
        for my $e ( keys %$heads ) {
            push @$lists, @{ $heads->{ $e } };
        }
        return $lists;
    }
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

sub smtpagent {
    # @abstract Return MTA name: Call smtpagent() in each child class
    # @return   [String] MTA name
    my $class = shift; 
    return shift // 'null';
}

sub index {
    # MTA list
    # @return   [Array] MTA list with order
    my $class = shift;
    my $index = [
        'Sendmail', 'Postfix', 'qmail', 'OpenSMTPD', 'Exim', 'Courier',
        'Exchange', 'MessagingServer', 'V5sendmail', 'ApacheJames', 'McAfee', 
        'Domino', 'Notes', 'MXLogic', 'MailFoundry', 'IMailServer', 'mFILTER', 
        'Activehunter', 'InterScanMSS', 'SurfControl', 'MailMarshalSMTP',
        'X1', 'X2', 'X3', 'X4', 'X5',
    ];

    return $index;
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

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
