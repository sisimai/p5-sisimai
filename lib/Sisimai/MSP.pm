package Sisimai::MSP;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::MTA;

sub description    { '' }
sub headerlist     { [] }
sub SMTPCOMMAND    { return Sisimai::MTA->SMTPCOMMAND    }
sub EOM            { return Sisimai::MTA->EOM            }
sub DELIVERYSTATUS { return Sisimai::MTA->DELIVERYSTATUS }
sub LONGFIELDS     { return Sisimai::MTA->LONGFIELDS     }
sub INDICATORS     { return Sisimai::MTA->INDICATORS     }
sub RFC822HEADERS  { 
    my $class = shift;
    my $argvs = shift;
    return Sisimai::MTA->RFC822HEADERS( $argvs );
}

sub smtpagent {
    # Return MSP name: Call smtpagent() in each child class
    # @return   [String] MSP name
    my $class = shift; 
    return shift // 'null';
}

sub index {
    # MSP list
    # @return   [Array] MSP list with order
    my $class = shift;
    my $index = [
        'US::Google', 'US::Yahoo', 'US::Aol', 'US::Outlook',
        'US::AmazonSES', 'US::SendGrid',
        'JP::EZweb', 'JP::KDDI', 'JP::Biglobe',
        'US::Verizon', 'RU::MailRu', 'RU::Yandex', 'DE::GMX', 'DE::EinsUndEins',
        'US::Zoho', 'US::Bigfoot', 'US::Facebook', 'UK::MessageLabs',
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
