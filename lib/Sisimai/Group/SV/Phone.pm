package Sisimai::Group::SV::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of El Salvador 
        'claro' => [
            # Claro; http://www.claro.com.sv/
            qr/\Aclaroguatemala[.]blackberry[.]com\z/,  # El Salvador ?
        ],
        'movistar' => [
            # Movistar El Salvador; http://movistar.com.sv/
            qr/\Amovistar[.]sv[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SV::Phone - Major phone provider's domains in El Salvador

=head1 SYNOPSIS

    use Sisimai::Group::SV::Phone;
    print Sisimai::Group::SV::Phone->find('movistar.sv.blackberry.com');   # movistar

=head1 DESCRIPTION

Sisimai::Group::SV::Phone has a domain list of major cellular phone providers
and major smart phone providers in El Salvador.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
