package Sisimai::MTA;
use feature ':5.10';
use strict;
use warnings;

sub version     { return '4.0.2' }
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
        if( exists $heads->{ $group } ) {
            return $heads->{ $group };

        } else {
            # Return all the values when the group name does not exist
            return $heads;
        }
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
    my $class = shift; 
    return shift // 'null';
}

sub scan {
    # @Description  Detect an error
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    return '';
#     my $RxMTA = {};
# 
#     my $class = shift;
#     my $mhead = shift // return undef;
#     my $mbody = shift // return undef;
# 
#     # return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};
#     # return undef unless $mhead->{'from'}    =~ $RxMTA->{'from'};
# 
#     my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
#     my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
#     my $rfc822part = '';    # (String) message/rfc822-headers part
#     my $previousfn = '';    # (String) Previous field name
# 
#     my $stripedtxt = [ split( "\n", $$mbody ) ];
#     my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
#     my $rcptintext = '';    # (String) Recipient address in the message body
#     my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
#     my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
#     my $connheader = {
#         'date'    => '',    # The value of Arrival-Date header
#         'lhost'   => '',    # The value of Received-From-MTA header
#         'rhost'   => '',    # The value of Reporting-MTA header
#     };
# 
#     my $v = undef;
#     my $p = '';
#     push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
#     $rfc822head = __PACKAGE__->RFC822HEADERS;
# 
#     # 1. Email headers in the bounce mail
#     # 2. Delivery status
#     # 3. message/rfc822 part
#     # 4. Original message
#     for my $e ( @$stripedtxt ) {
#         # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
#         if( ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
#             # After "message/rfc822"
# 
#         } else {
#             # Before "message/rfc822"
#             next unless ( $e =~ $RxMTA->{'begin'} ) .. ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } );
#             next unless length $e;
# 
#             if( $connvalues == scalar( keys %$connheader ) ) {
#                 # Parse delivery status
#             } else {
#                 # Get headers related the smtp session/connection
#             }
#         } # End of if: rfc822
# 
#     } continue {
#         # Save the current line for the next loop
#         $p = $e;
#         $e = '';
#     }
# 
#     return undef unless $recipients;
#     for my $e ( @$dscontents ) {
#         # Set default values if each value is empty.
#         for my $f ( 'date', 'lhost', 'rhost' ) {
#             $e->{ $f }  ||= $connheader->{ $f } || '';
#         }
#         $e->{'agent'}   ||= __PACKAGE__->smtpagent;
#         $e->{'command'} ||= $commandtxt;
#     }
#     return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
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
