package Sisimai::Group::LU::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Grand Duchy of Luxembourg 
        'luxgsm' => [
            # LuxGSM; http://www.luxgsm.lu/ 
            qr/\Amobileemail[.]luxgsm[.]lu\z/,
        ],
        'orange' => [
            # Orange Luxembourg; http://orange.lu/
            # And see ../Smartphone.pm
            qr/\Avoxmobile[.]blackberry[.]com\z/,
        ],
        'tango' => [
            # Tango; http://www.tango.lu/
            qr/\Atango[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::LU::Phone - Major phone provider's domains in Luxembourg

=head1 SYNOPSIS

    use Sisimai::Group::LU::Phone;
    print Sisimai::Group::LU::Phone->find('tango.blackberry.com'); # tango

=head1 DESCRIPTION

Sisimai::Group::LU::Phone has a domain list of major cellular phone providers
and major smart phone providers in Luxembourg.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
