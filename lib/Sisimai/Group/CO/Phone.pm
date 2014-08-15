package Sisimai::Group::CO::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Colombia
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'claro' => [
            # http://www.americamovil.com/
            qr/\Aiclaro[.]com[.]co\z/,
        ],
        'comcel' => [
            # Comcel Colombia; http://www.comcel.com/
            qr/\Acomcel[.]com[.]co\z/,
            qr/\Acomcel[.]blackberry[.]com\z/,
        ],
        'millicom' => [
            # Millicom International Cellular, also known as Tigo,
            # http://www.tigo.com/, http://www.millicom.com/
            qr/\Asms[.]tigo[.]com[.]co\z/,
        ],
        'movistar' => [
            qr/\Amovistar[.]com[.]co\z/,             # Movistar; http://www.telefonica.com/
            qr/\Amovistar[.]co[.]blackberry[.]com\z/,# movistar; http://www.movistar.com.co/
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CO::Phone - Major phone provider's domains in Colombia

=head1 SYNOPSIS

    use Sisimai::Group::CO::Phone;
    print Sisimai::Group::CO::Phone->find('iclaro.com.co');    # claro

=head1 DESCRIPTION

Sisimai::Group::CO::Phone has a domain list of major cellular phone providers
and major smart phone providers in Colombia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
