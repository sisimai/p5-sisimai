package Sisimai::Group::GT::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Guatemala
        'claro' => [
            # Claro; http://www.claro.com.gt/
            qr/\Aclaroguatemala[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # Movistar http://www.movistar.com.gt/
            qr/\Amovistar[.]gt[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::GT::Phone - Major phone provider's domains in Guatemala

=head1 SYNOPSIS

    use Sisimai::Group::GT::Phone;
    print Sisimai::Group::GT::Phone->find('movistar.gt.blackberry.com');   # movistar

=head1 DESCRIPTION

Sisimai::Group::GT::Phone has a domain list of major cellular phone providers
and major smart phone providers in Guatemala.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
