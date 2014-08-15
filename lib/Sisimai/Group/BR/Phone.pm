package Sisimai::Group::BR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Brazil
        'claro' => [
            # Claro; http://www.americamovil.com/
            qr/\Aclarotorpedo[.]com[.]br\z/,
            qr/\Aclaro[.]blackberry[.]com\z/,
        ],
        'nextel' => [
            # NEXTEL; http://m.nextel.com.br/
            qr/\Anextel[.]br[.]blackberry[.]com\z/,
        ],
        'oi' => [
            # Oi; http://www.oi.com.br/
            qr/\Aoi[.]blackberry[.]com\z/,
        ],
        'tim' => [
            # TIM Brasil; http://www.tim.com.br/
            qr/\Atimbrasil[.]blackberry[.]com\z/,
        ],
        'vivo' => [
            # Vivo S.A.; http://www.vivo.com.br/
            qr/\Atorpedoemail[.]com[.]br\z/,
            qr/\Avivo[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BR::Phone - Major phone provider's domains in Brazil

=head1 SYNOPSIS

    use Sisimai::Group::BR::Phone;
    print Sisimai::Group::BR::Phone->find('claro.blackberry.com'); # claro

=head1 DESCRIPTION

Sisimai::Group::BR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Brazil.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
