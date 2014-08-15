package Sisimai::Group::BS::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Commonwealth of The Bahamas
        'btcbahamas' => [
            # BTC Bahamas; http://www2.btcbahamas.com/
            qr{\Abtccybercell[.]blackberry[.]com\z},
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BS::Phone - Major phone provider's domains in Bahamas

=head1 SYNOPSIS

    use Sisimai::Group::BS::Phone;
    print Sisimai::Group::BS::Phone->find('btccybercell.blackberry.com');  # btcbahamas

=head1 DESCRIPTION

Sisimai::Group::BS::Phone has a domain list of major cellular phone providers
and major smart phone providers in Bahamas.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
