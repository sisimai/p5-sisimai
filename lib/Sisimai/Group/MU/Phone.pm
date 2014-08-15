package Sisimai::Group::MU::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Mauritius
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'emtel' => [
            # Emtel; http://www.emtel.mu/
            qr/\Aemtelworld[.]net\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MU::Phone - Major phone provider's domains in Maulitius

=head1 SYNOPSIS

    use Sisimai::Group::MU::Phone;
    print Sisimai::Group::MU::Phone->find('emtelworld.net');   # emtel

=head1 DESCRIPTION

Sisimai::Group::MU::Phone has a domain list of major cellular phone providers
and major smart phone providers in Maulitius.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
