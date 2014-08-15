package Sisimai::Group::SG::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Singapore
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'm1' => [
            # M1; http://m1.com.sg/M1/site/M1Corp/
            qr/\Am1[.]com[.]sg\z/,
            qr/\Am1[.]blackberry[.]com\z/,
        ],
        'singtel' => [
            # SingTel; http://info.singtel.com/
            qr/\Asingtel[.]blackberry[.]com\z/,
        ],
        'starhub' => [
            # StarHub; http://www.starhub.com/
            qr/\Astarhub-enterprisemessaing[.]com\z/,
            qr/\Astarhub[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SG::Phone - Major phone provider's domains in Singapore

=head1 SYNOPSIS

    use Sisimai::Group::SG::Phone;
    print Sisimai::Group::SG::Phone->find('m1.com.sg');    # m1

=head1 DESCRIPTION

Sisimai::Group::SG::Phone has a domain list of major cellular phone providers
and major smart phone providers in Singapore.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
