package Sisimai::Group::FR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in French Republic
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'bouygues' => [
            # Bouygues Telecom; http://www.bouyguestelecom.fr/
            qr/\Amms[.]bouyguestelecom[.]fr/,
            qr/\Abouyguestelecom[.]blackberry[.]com\z/,
        ],
        'sfr' => [
            # SFR/La Reunion; http://sfr.re/
            # Vodafone?
            qr/\Asfrre[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::FR::Phone - Major phone provider's domains in France

=head1 SYNOPSIS

    use Sisimai::Group::FR::Phone;
    print Sisimai::Group::FR::Phone->find('sfrre.blackberry.com'); # sfr

=head1 DESCRIPTION

Sisimai::Group::FR::Phone has a domain list of major cellular phone providers
and major smart phone providers in France.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
