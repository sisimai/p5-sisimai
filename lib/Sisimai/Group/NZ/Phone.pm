package Sisimai::Group::NZ::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in New Zealand
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'telecomnz' => [
            # Telecom New Zealand; http://www.telecom.co.nz/home/
            qr/\Aetxt[.]co[.]nz\z/,
            qr/\Atnz[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.co.nz/
            qr/\Asms[.]vodafone[.]net[.]nz\z/,
            qr/\Amtxt[.]co[.]nz\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NZ::Phone - Major phone provider's domains in New Zealand

=head1 SYNOPSIS

    use Sisimai::Group::NZ::Phone;
    print Sisimai::Group::NZ::Phone->find('mtxt.co.nz');    # telecomnz

=head1 DESCRIPTION

Sisimai::Group::NZ::Phone has a domain list of major cellular phone providers
and major smart phone providers in New Zealand.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
