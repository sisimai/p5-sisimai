package Sisimai::Group::PE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Peru
        'claro' => [
            # Claro; http://www.claro.com.pe/
            qr/\Aclaroperu[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # movistar; http://movistar.com.pe/
            qr/\Amovistar[.]pe[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PE::Phone - Major phone provider's domains in Peru

=head1 SYNOPSIS

    use Sisimai::Group::PE::Phone;
    print Sisimai::Group::PE::Phone->find('claroberu.blackberry.com'); # claro

=head1 DESCRIPTION

Sisimai::Group::PE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Peru.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
