package Sisimai::Group::DE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Federal Republic of Germany/Bundesrepublik Deutschland
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'e-plus' => [
            # E-Plus; http://www.eplus.de/
            qr/\Asmsmail[.]eplus[.]de\z/,
            qr/\Aeplus[.]blackberry[.]com\z/,
        ],
        'o2' => [
            # Telefonica; o2online.de
            qr/\Ao2online[.]de\z/,
            qr/\Ao2[.]blackberry[.]de\z/,
        ],
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.net/
            qr/\At-d1-sms[.]de\z/,
            qr/\At-mobile-sms[.]de\z/,
            qr/\Ainstantemail[.]t-mobile[.]de\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.com/
            qr/\Avodafone-sms[.]de\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::DE::Phone - Major phone provider's domains in Germany

=head1 SYNOPSIS

    use Sisimai::Group::DE::Phone;
    print Sisimai::Group::DE::Phone->find('vodafone-sms.de');    # vodafone

=head1 DESCRIPTION

Sisimai::Group::DE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Germany.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
