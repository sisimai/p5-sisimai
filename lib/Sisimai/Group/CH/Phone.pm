package Sisimai::Group::CH::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Switzerland/Swiss Confederation/Confoederatio Helvetica
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'boxis' => [
            # Box Internet Services SMS Gateway; http://www.boxis.net/en/sms-gateway/
            qr/\A(?:sms|mms)[.]boxis[.]net\z/,  # SMS, MMS
        ],
        'sunrise' => [
            # Sunrise; http://www1.sunrise.ch/
            qr/\Agsm[.]sunrise[.]ch\z/,
            qr/\Asunrise[.]blackberry[.]com\z/,
        ],
        # Domain unknown: Orange, Swisscom,
        'swisscom' => [
            # Swisscom; http://en.swisscom.ch/
            qr/\Amobileemail[.]swisscom[.]ch\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CH::Phone - Major phone provider's domains in Switzerland

=head1 SYNOPSIS

    use Sisimai::Group::CH::Phone;
    print Sisimai::Group::CH::Phone->find('sms.boxis.net');    # boxis

=head1 DESCRIPTION

Sisimai::Group::CH::Phone has a domain list of major cellular phone providers
and major smart phone providers in Switzerland.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
