package Sisimai::Group::VE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Bolivarian Republic of Venezuela
        'movilnet' => [
            # MOVILNET; http://www.movilnet.com.ve/
            qr/\Amovilnet[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # movistar; http://movistar.com.ve/
            qr/\Amovistar[.]ve[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::VE::Phone - Major phone provider's domains in Venezuela

=head1 SYNOPSIS

    use Sisimai::Group::VE::Phone;
    print Sisimai::Group::VE::Phone->find('movistar.ve.blackberry.com');   # movistar

=head1 DESCRIPTION

Sisimai::Group::VE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Venezuela.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
