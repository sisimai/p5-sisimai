package Sisimai::Group::ES::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Kingdom of Spain
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'esendex' => [
            # Esendex; http://esendex.es/
            qr/\Aesendex[.]net\z/,
        ],
        'movistar' => [
            # Telefonica Movistar; http://www.movistar.es/
            qr/\Acorreo[.]movistar[.]net\z/,    # ...?
            qr/\Amovistar[.]net\z/,
        ],
        'orange' => [
            # Orange, previously known as Amena; http://www.orange.es/
            qr/\Aamena[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.es/ 
            qr/\Avodafone[.]es\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ES::Phone - Major phone provider's domains in Kingdom of Spain

=head1 SYNOPSIS

    use Sisimai::Group::ES::Phone;
    print Sisimai::Group::ES::Phone->find('vodafone.es');    # vodafone

=head1 DESCRIPTION

Sisimai::Group::ES::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kingdom of Spain.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
