package Sisimai::MTA;
use feature ':5.10';
use strict;
use warnings;

sub version     { return '4.0.7' }
sub description { return '' }
sub headerlist  { return [] }

sub SMTPCOMMAND {
    return {
        'helo' => qr/\b(?:HELO|EHLO)\b/,
        'mail' => qr/\bMAIL F(?:ROM|rom)\b/,
        'rcpt' => qr/\bRCPT T[Oo]\b/,
        'data' => qr/\bDATA\b/,
    };
}
sub EOM { '__END_OF_EMAIL_MESSAGE__' };
sub DELIVERYSTATUS {
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
        'softbounce'   => -1,   # Soft bounce or not
        'feedbacktype' => '',   # FeedBack Type
    };
}

sub LONGFIELDS {
    # Fields that might be long
    return [ 'To', 'From', 'Subject' ];
}

sub RFC822HEADERS {
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

sub smtpagent {
    # @Description  Return MTA name: Call smtpagent() in each child class
    # @Param        None
    # @Return       (String) MTA name
    my $class = shift; 
    return shift // 'null';
}

sub index {
    # @Description  MTA list
    # @Param        None
    # @Return       (Ref->Array) MTA list with order
    my $class = shift;
    my $index = [
        'Sendmail', 'Postfix', 'qmail', 'OpenSMTPD', 'Exim', 'Courier',
        'Exchange', 'MessagingServer', 'V5sendmail', 'McAfee', 'Domino', 'Notes',
        'MXLogic', 'MailFoundry', 'IMailServer', 'mFILTER', 'Activehunter',
        'InterScanMSS', 'SurfControl', 'MailMarshalSMTP',
        'X1', 'X2', 'X3',
    ];

    return $index;
}

sub scan {
    # @Description  Detect an error
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
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

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
