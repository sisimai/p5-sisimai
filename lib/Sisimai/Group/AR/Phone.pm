package Sisimai::Group::AR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Argentina/Argentine Republic
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'claro' => [
            # Claro, CTI Movil
            qr/\Asms[.]ctimovil[.]com[.]ar\z/,
            qr/\Aclaroar[.]blackberry[.]com\z/,
        ],
        'nextel' => [
            # NEXTEL ARGENTINA; http://www.nextel.com.ar/
            qr/\Anextel[.]net[.]ar\z/,
        ],
        'personal' => [
            # Telecom Personal S.A.; http://www.telecom.com.ar/
            qr/\Aalertas[.]personal[.]com[.]ar\z/,
            qr/\Atelecompersonal[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # Movistar; http://www.movistar.com/
            qr/\Amovistar[.]com[.]ar\z/,
            qr/\Asms[.]movistar[.]net[.]ar\z/,
            qr/\Amovimensaje[.]com[.]ar\z/,
            qr/\Amovistar[.]ar[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AR::Phone - Major phone provider's domains in Argentine

=head1 SYNOPSIS

    use Sisimai::Group::AR::Phone;
    print Sisimai::Group::AR::Phone->find('nextel.net.ar');    # nextel

=head1 DESCRIPTION

Sisimai::Group::AR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Argentine.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
