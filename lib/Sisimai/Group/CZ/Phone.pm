package Sisimai::Group::CZ::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Czech Republic
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'o2' => [
            # O2; http://www.o2online.cz/
            qr/\Ao2[.]blackberry[.]cz\z/,
        ],
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.cz/
            qr/\Atmobilecz[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.cz/en/
            qr/\Avodafonemail[.]cz\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CZ::Phone - Major phone provider's domains in Czech Republic

=head1 SYNOPSIS

    use Sisimai::Group::CZ::Phone;
    print Sisimai::Group::CZ::Phone->find('vodafonemail.cz');  # vodafone

=head1 DESCRIPTION

Sisimai::Group::CZ::Phone has a domain list of major cellular phone providers
and major smart phone providers in Czech Republic.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
