package Sisimai::Group::PH::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of the Philippines/Republika ng Pilipinas
        'globetelecom' => [
            # Globe Telecom; http://www.globe.com.ph/
            qr/\Aglobe[.]blackberry[.]com\z/,
        ],
        'smartcomm' => [
            # Smart Communications; http://smart.com.ph/
            qr/\Asmart[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PH::Phone - Major phone provider's domains in Philippines

=head1 SYNOPSIS

    use Sisimai::Group::PH::Phone;
    print Sisimai::Group::PH::Phone->find('smart.blackberry.com'); # smartcomm

=head1 DESCRIPTION

Sisimai::Group::PH::Phone has a domain list of major cellular phone providers
and major smart phone providers in Philippines.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
