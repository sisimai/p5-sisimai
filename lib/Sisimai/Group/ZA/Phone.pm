package Sisimai::Group::ZA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in South Africa/Zuid-Afrika
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'cellc' => [
            # Cell C South Africa; http://www.cellc.co.za/
            qr/\Acellc[.]blackberry[.]com\z/,
        ],
        'mtngroup' => [
            # MTN Group; http://www.mtn.com/
            qr/\Asms[.]co[.]za\z/,
            qr/\Amtn[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodacom; http://www.vodacom.co.za/
            qr/\Avoda[.]co[.]za\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ZA::Phone - Major phone provider's domains in South Africa

=head1 SYNOPSIS

    use Sisimai::Group::ZA::Phone;
    print Sisimai::Group::ZA::Phone->find('voda.co.za');    # vodafone

=head1 DESCRIPTION

Sisimai::Group::ZA::Phone has a domain list of major cellular phone providers
and major smart phone providers in South Africa.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
