package Sisimai::Group::AW::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Aruba
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'setar' => [
            # SETAR NV; http://www.setar.aw/
            qr/\Amas[.]aw\z/,   #  297domestic-number@
            qr/\Asetar[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AW::Phone - Major phone provider's domains in Aruba

=head1 SYNOPSIS

    use Sisimai::Group::AW::Phone;
    print Sisimai::Group::AW::Phone->find('mas.aw');   # setar

=head1 DESCRIPTION

Sisimai::Group::AW::Phone has a domain list of major cellular phone providers
and major smart phone providers in Aruba.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
