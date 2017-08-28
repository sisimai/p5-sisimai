package Sisimai::MSP;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC5322;
use Sisimai::Skeleton;

sub DELIVERYSTATUS {
    warn sprintf(" ***warning: %s->DELIVERYSTATUS has been moved to Sisimai::Bite->DELIVERYSTATUS\n", __PACKAGE__);
    return Sisimai::Skeleton->DELIVERYSTATUS;
}
sub INDICATORS {
    warn sprintf(" ***warning: %s->DELIVERYSTATUS has been moved to Sisimai::Bite::Email->INDICATORS\n", __PACKAGE__);
    return Sisimai::Skeleton->INDICATORS;
}
sub smtpagent { 
    warn sprintf(" ***warning: %s->smtpagent has been moved to Sisimai::Bite->smtpagent\n", __PACKAGE__);
    my $v = shift;
    $v =~ s/\ASisimai:://;
    return $v;
}
sub description {
    warn sprintf(" ***warning: %s->description has been moved to Sisimai::Bite->description\n", __PACKAGE__);
    return '';
}
sub headerlist {
    warn sprintf(" ***warning: %s->headerlist has been moved to Sisimai::Bite::Email->headerlist\n", __PACKAGE__);
    return [];
}
sub pattern {
    warn sprintf(" ***warning: %s->pattern has been moved to Sisimai::Bite::Email->pattern\n", __PACKAGE__);
    return {};
}

sub index {
    # MSP list
    # @return   [Array] MSP list with order
    my $class = shift;
    my $index = [
        'US::Google', 'US::Yahoo', 'US::Aol', 'US::Outlook', 'US::AmazonSES', 
        'US::SendGrid', 'US::GSuite', 'US::Verizon', 'RU::MailRu', 'RU::Yandex',
        'DE::GMX', 'US::Bigfoot', 'US::Facebook', 'US::Zoho', 'DE::EinsUndEins',
        'UK::MessageLabs', 'JP::EZweb', 'JP::KDDI', 'JP::Biglobe',
        'US::ReceivingSES', 'US::AmazonWorkMail', 'US::Office365',
    ];
    return $index;
}

sub scan {
    # Detect an error
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
    return undef;
}

1;

package Sisimai::MSP::DE::EinsUndEins; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::DE::GMX; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::JP::Biglobe; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::JP::EZweb; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::JP::KDDI; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::RU::MailRu; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::RU::Yandex; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::UK::MessageLabs; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::AmazonSES; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::AmazonWorkMail; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Aol; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Bigfoot; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Facebook; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Google; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::GSuite; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Office365; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Outlook; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::ReceivingSES; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::SendGrid; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Verizon; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Yahoo; use parent 'Sisimai::MSP'; 1;
package Sisimai::MSP::US::Zoho; use parent 'Sisimai::MSP'; 1;

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

Copyright (C) 2014-2017 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
