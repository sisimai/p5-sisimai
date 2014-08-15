package Sisimai::Group::BE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Kingdom of Belgium
        'base' => [
            # BASE; http://www.base.be/
            qr/\Abase[.]blackberry[.]com\z/,
        ],
        'mobistar' => [
            # Mobistar; http://www.mobistar.be/
            qr/\Ablackberry[.]mobistar[.]be\z/,
        ],
        'proximus' => [
            # Proximus; http://www.proximus.be/
            qr/\Aproximus[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BE::Phone - Major phone provider's domains in Kingdom of Belgium

=head1 SYNOPSIS

    use Sisimai::Group::BE::Phone;
    print Sisimai::Group::BE::Phone->find('blackberry.mobistar.be');   # mobistar

=head1 DESCRIPTION

Sisimai::Group::BE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kingdom of Belgium.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
