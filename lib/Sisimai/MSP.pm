package Sisimai::MSP;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::MTA;
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
sub DELIVERYSTATUS { return Sisimai::MTA->DELIVERYSTATUS }
sub LONGFIELDS     { return Sisimai::MTA->LONGFIELDS     }
sub INDICATORS     { return Sisimai::MTA->INDICATORS     }
sub RFC822HEADERS { 
    # Grouped RFC822 headers
    # @private
    # @deprecated
    # @param    [String] group  RFC822 Header group name
    # @return   [Array,Hash]    RFC822 Header list
    my $class = shift;
    my $group = shift // return [ keys %{ Sisimai::RFC5322->HEADERFIELDS } ];
    my $index = Sisimai::RFC5322->HEADERFIELDS( $group );
    return $index;
}

sub smtpagent      { return Sisimai::MTA->smtpagent      }
sub description    { return '' }
sub headerlist     { return [] }
sub pattern        { return {} }

sub index {
    # MSP list
    # @return   [Array] MSP list with order
    my $class = shift;
    my $index = [
        'US::Google', 'US::Yahoo', 'US::Aol', 'US::Outlook', 'US::AmazonSES', 
        'US::SendGrid', 'US::Verizon', 'RU::MailRu', 'RU::Yandex', 'DE::GMX', 
        'US::Bigfoot', 'US::Facebook', 'US::Zoho', 'DE::EinsUndEins',
        'UK::MessageLabs', 'JP::EZweb', 'JP::KDDI', 'JP::Biglobe',
        'US::ReceivingSES',
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

Sisimai::MSP - Base class for Sisimai::MSP::*, Mail Service Provider classes.

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::MSP::*, such as Sisimai::MSP::Google,
instead.

=head1 DESCRIPTION

Sisimai::MSP is a base class for Sisimai::MSP::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
