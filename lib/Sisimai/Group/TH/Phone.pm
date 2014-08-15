package Sisimai::Group::TH::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in The Kingdom of Thailand
        'ais' => [
            # AIS; http://www.ais.co.th
            qr/\Aaiscorporatemail[.]blackberry[.]com\z/,
        ],
        'dtac' => [
            # dtac; http://www.dtac.co.th/
            qr/\Adtac[.]blackberry[.]com\z/,
        ],
        'truemove' => [
            # Truemove; http://www.truemove.com/th/
            qr/\Atruemove[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::TH::Phone - Major phone provider's domains in Thailand

=head1 SYNOPSIS

    use Sisimai::Group::TH::Phone;
    print Sisimai::Group::TH::Phone->find('truemove.blackberry.com');  # truemove

=head1 DESCRIPTION

Sisimai::Group::TH::Phone has a domain list of major cellular phone providers
and major smart phone providers in Thailand.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
