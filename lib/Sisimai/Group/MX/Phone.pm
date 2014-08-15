package Sisimai::Group::MX::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in United Mexican States
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'iusacell' => [
            # Iusacell; http://www.iusacell.com.mx/
            qr/\Aiusacell[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # movistar; http://movistar.com.mx/
            qr/\Amovistar[.]mx[.]blackberry[.]com\z/,
        ],
        'nextel' => [
            # Nextel de Mexico; http://nextel.com.mx/
            qr/\Amsgnextel[.]com[.]mx\z/,
        ],
        'telcel' => [
            # Telcel; http://telcel.com.mx/ 
            qr/\Atelcel[.]blackberry[.](?:com|net)\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MX::Phone - Major phone provider's domains in United Mexican States

=head1 SYNOPSIS

    use Sisimai::Group::MX::Phone;
    print Sisimai::Group::MX::Phone->find('msgnextel.com.mx'); # nextel

=head1 DESCRIPTION

Sisimai::Group::MX::Phone has a domain list of major cellular phone providers
and major smart phone providers in United Mexican States.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
