package Sisimai::Group::JM::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Jamaica
        'claro' => [
            # Claro Jamaica; http://claro.com.jm/
            qr/\Aclarojm[.]blackberry[.]com\z/,
        ],
        'lime' => [
            # LIME Jamaica; http://www.time4lime.com/jm/
            qr/\Acwjamaica[.]blackberry[.](?:com|net)\z/,
            qr/\Acw[.]blackberry[.](?:com|net)\z/,
        ],
        'digicel' => [
            # Digicel Jamaica Cellular; http://www.digiceljamaica.com/
            qr/\Adigicel[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::JM::Phone - Major phone provider's domains in Jamaica

=head1 SYNOPSIS

    use Sisimai::Group::JM::Phone;
    print Sisimai::Group::JM::Phone->find('digicel.blackberry.com');   # digicel

=head1 DESCRIPTION

Sisimai::Group::JM::Phone has a domain list of major cellular phone providers
and major smart phone providers in Jamaica.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
