package Sisimai::Group::CA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Canada
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'aliant' => [
            # Bell Aliant; http://bell.aliant.ca/
            qr/\Awirefree[.]informe[.]ca\z/,
            qr/\Asms[.]wirefree[.]informe[.]ca\z/,
        ],
        'bell' => [
            # Bell Canada; http://www.bell.ca/
            qr/\Atxt[.]bell(?:mobility)?.ca\z/,
            qr/\Abellmobility[.]ca\z/,
            qr/\Abell[.]blackberry[.](?:com|net)\z/,
        ],
        'fido' => [
            # Fido Solutions; http://www.fido.ca/
            qr/\Afido[.]ca\z/,
            qr/\Asms[.]fido[.]ca\z/,
            qr/\Afido[.]blackberry[.](?:com|net)\z/,
        ],
        'lynxmobility' => [
            # Lynx Mobility
            qr/\Asms[.]lynxmobility[.]com/,
        ],
        'mts' => [
            # Manitoba Telecom Services; http://www.mts.ca/
            qr/\Atext[.]mtsmobility[.]com\z/,
            qr/\Amtsm[.]blackberry[.]com\z/,
        ],
        'presidentschoice' => [
            # President's Choice: PC; http://www.presidentschoice.ca/
            qr/\Amobiletxt[.]ca\z/,
        ],
        'rogers' => [
            # Rogers Wireless; http://www.rogers.com/wireless
            qr/\A(?:pcs|mms)[.]rogers[.]com\z/,
            qr/\Arogers[.]blackberry[.](?:com|net)\z/,
        ],
        'sasktel' => [
            # SaskTel; http://www.sasktel.com/
            qr/\Asms[.]sasktel[.]com\z/,
            qr/\Apcs[.]sasktelmobility[.]com\z/,
        ],
        'tbaytel' => [
            # Tbaytel; http://www.tbaytel.net/
            qr/\Atbaytel[.]blackberry[.]com\z/,
        ],
        'telus' => [
            # Telus; http://www.telus.com/
            #  See Koodo Mobile; http://www.koodomobile.com/
            qr/\Amsg[.]telus[.]com\z/,
            qr/\Amms[.]telusmobility[.]com\z/,
            qr/\Atelus[.]blackberry[.](?:com|net)\z/,
        ],
        'virgin' => [
            # Virgin Mobile; http://www.virginmobile.com/
            qr/\Avmobile[.]ca\z/,
            qr/\Avirginmobile[.]blackberry[.]com\z/,
        ],
        'windmobile' => [
            # Wind Mobile; http://www.windmobile.ca/
            qr/\Atxt[.]windmobile[.]ca\z/,
            qr/\Awind[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CA::Phone - Major phone provider's domains in Canada

=head1 SYNOPSIS

    use Sisimai::Group::CA::Phone;
    print Sisimai::Group::CA::Phone->find('vmobile.ca');    # virgin

=head1 DESCRIPTION

Sisimai::Group::CA::Phone has a domain list of major cellular phone providers
and major smart phone providers in Canada.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
