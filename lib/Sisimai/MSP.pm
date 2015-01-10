package Sisimai::MSP;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::MTA;

sub version     { return '4.0.12' }
sub description { return '' }
sub headerlist  { return [] }

sub SMTPCOMMAND    { return Sisimai::MTA->SMTPCOMMAND    }
sub EOM            { return Sisimai::MTA->EOM            }
sub DELIVERYSTATUS { return Sisimai::MTA->DELIVERYSTATUS }
sub LONGFIELDS     { return Sisimai::MTA->LONGFIELDS     }
sub RFC822HEADERS  { 
    my $class = shift;
    my $argvs = shift;
    return Sisimai::MTA->RFC822HEADERS( $argvs );
}

sub smtpagent {
    # @Description  Return MSP name: Call smtpagent() in each child class
    # @Param        None
    # @Return       (String) MSP name
    my $class = shift; 
    return shift // 'null';
}

sub index {
    # @Description  MSP list
    # @Param        None
    # @Return       (Ref->Array) MSP list with order
    my $class = shift;
    my $index = [
        'US::Google', 'US::Yahoo', 'US::Aol', 'US::Outlook',
        'US::AmazonSES', 'US::SendGrid',
        'JP::EZweb', 'JP::KDDI', 'JP::Biglobe',
        'US::Verizon', 'RU::MailRu', 'RU::Yandex', 'DE::GMX', 'DE::EinsUndEins',
        'US::Zoho', 'US::Bigfoot', 'US::Facebook', 'UK::MessageLabs',
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

Sisimai::MSP - Base class for Sisimai::MSP::*, Mail Service Provider classes.

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::MSP::*, such as Sisimai::MSP::Google,
instead.

=head1 DESCRIPTION

Sisimai::MSP is a base class for Sisimai::MSP::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
