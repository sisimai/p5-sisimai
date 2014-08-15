package Sisimai::Group::NI::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Nicaragua
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'claro' => [
            qr/\Aideasclaro-ca[.]com\z/,                # Claro; http://www.americamovil.com/
            qr/\Aclaronicaragua[.]blackberry[.]com\z/,  # Claro; http://www.claro.com.ni/
        ],
        'movistar' => [
            # movistar; http://movistar.com.ni/
            qr/\Amovistar[.]ni[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NI::Phone - Major phone provider's domains in Nicaragua

=head1 SYNOPSIS

    use Sisimai::Group::NI::Phone;
    print Sisimai::Group::NI::Phone->find('ideasclaro-ca.com');    # claro

=head1 DESCRIPTION

Sisimai::Group::NI::Phone has a domain list of major cellular phone providers
and major smart phone providers in Nicaragua.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
