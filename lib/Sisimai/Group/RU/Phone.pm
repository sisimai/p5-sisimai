package Sisimai::Group::RU::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Russian Federation
        'beeline' => [
            # http://www.beeline.ru/
            qr/\Abeeline[.]blackberry[.]com\z/,
        ],
        'mtc' => [
            # MTC; http://www.mts.ru/
            qr/\Amts(?:ru)?[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::RU::Phone - Major phone provider's domains in Russia

=head1 SYNOPSIS

    use Sisimai::Group::RU::Phone;
    print Sisimai::Group::RU::Phone->find('mts.blackberry.com');    # mtc

=head1 DESCRIPTION

Sisimai::Group::RU::Phone has a domain list of major cellular phone providers
and major smart phone providers in Russia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
