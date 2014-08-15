package Sisimai::Group::NO::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Norway
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'sendega' => [
            # Sendega; http://www.sendega.no
            qr/\Asendega[.]com\z/,
        ],
        'telenor' => [
            # Telenor; http://www.telenor.no/
            qr/\Atelenor[.]?no[.]blackberry[.]com\z/,
            qr/\Atelenor[.]blackberry[.]com\z/,
        ],
        'teletopiasms' => [
            # TeletopiaSMS; http://www.teletopiasms.no/
            qr/\Asms[.]teletopiasms[.]no\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NO::Phone - Major phone provider's domains in Norway

=head1 SYNOPSIS

    use Sisimai::Group::NO::Phone;
    print Sisimai::Group::NO::Phone->find('sendega.com');    # sendega

=head1 DESCRIPTION

Sisimai::Group::NO::Phone has a domain list of major cellular phone providers
and major smart phone providers in Norway.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
