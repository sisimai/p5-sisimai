package Sisimai::Group::DO::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Dominica
        'claro' => [
            # Claro; http://www.claro.com.do/
            qr{\Aclarodr[.]blackberry[.]com\z},
        ],
        'digicel' => [
            # Digicel Dominica;
            qr{\Adigitextdm[.]com\z},
        ],
        'vivard' => [
            # Viva Dominican Republic; http://www.viva.com.do/
            qr{\Avivard[.]blackberry[.]com\z},
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::DO::Phone - Major phone provider's domains in Dominica

=head1 SYNOPSIS

    use Sisimai::Group::DO::Phone;
    print Sisimai::Group::DO::Phone->find('clarodr.blackberry.com');   # claro

=head1 DESCRIPTION

Sisimai::Group::DO::Phone has a domain list of major cellular phone providers
and major smart phone providers in Dominica.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
