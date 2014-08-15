package Sisimai::Group::CR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Costa Rica
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'ice' => [
            # ICE; http://www.grupoice.com/
            qr/\Aice[.]cr\z/,
            qr/\Asms[.]ice[.]cr\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CR::Phone - Major phone provider's domains in Csta Rica

=head1 SYNOPSIS

    use Sisimai::Group::CR::Phone;
    print Sisimai::Group::CR::Phone->find('sms.ice.cr');   # ice

=head1 DESCRIPTION

Sisimai::Group::CR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Csta Rica.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
