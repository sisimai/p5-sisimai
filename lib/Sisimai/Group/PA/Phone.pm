package Sisimai::Group::PA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Panama
        'claro' => [
            # Claro; http://www.claro.com.pa/
            qr/\Aclaropanama[.]blackberry[.]com\z/,
        ],
        'cwmovil' => [
            # Cable & Wireless Panama; http://www.cwmovil.com/
            qr/\Acwmovil[.]com\z/,
            qr/\Acwmovil[.]blackberry[.]com\z/,
        ],
        'digicel' => [
            # Digicel Panama; http://www.digicelpanama.com/
            qr/\Adigicel[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # movistar; http://movistar.com.pa/
            qr/\Amovistar[.]pa[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PA::Phone - Major phone provider's domains in Panama

=head1 SYNOPSIS

    use Sisimai::Group::PA::Phone;
    print Sisimai::Group::PA::Phone->find('cwmovil.com');  # cwmovil

=head1 DESCRIPTION

Sisimai::Group::PA::Phone has a domain list of major cellular phone providers
and major smart phone providers in Panama.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
