package Sisimai::Group::PL::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Poland
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'eragsm' => [
            # EraGSM; http://www.era.pl
            qr/\Aera[.]blackberry[.]com\z/,
        ],
        'orange' => [
            # Orange Polska; http://www.orange.pl/
            qr/\Aorange[.]pl\z/,
        ],
        'plusgsm' => [
            # Plus (previously: Plus GSM); http://www.plus.pl/english/
            qr/\Atext[.]plusgsm[.]pl\z/,    # +48domestic-number@
            qr/\Aiplus[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PL::Phone - Major phone provider's domains in Poland

=head1 SYNOPSIS

    use Sisimai::Group::PL::Phone;
    print Sisimai::Group::PL::Phone->find('orange.pl');    # orange

=head1 DESCRIPTION

Sisimai::Group::PL::Phone has a domain list of major cellular phone providers
and major smart phone providers in Poland.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
