package Sisimai::Group::ID::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Indonesia
        'indosat' => [
            # Indosat; http://www.indosat.com/
            qr/\Aindosat[.]blackberry[.]com\z/,
        ],
        'telkomsel' => [
            # Telkomsel; http://www.telkomsel.com/
            qr/\Atelkomsel[.]blackberry[.]com\z/,
        ],
        'xl' => [
            # XL; http://www.xl.co.id/
            qr/\Axl[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ID::Phone - Major phone provider's domains in Indonesia

=head1 SYNOPSIS

    use Sisimai::Group::ID::Phone;
    print Sisimai::Group::ID::Phone->find('xl.blackberry.com');    # xl

=head1 DESCRIPTION

Sisimai::Group::ID::Phone has a domain list of major cellular phone providers
and major smart phone providers in Indonesia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
