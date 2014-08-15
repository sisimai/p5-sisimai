package Sisimai::Group::CL::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Chile
        'claro' => [
            # Claro Chile; http://www.clarochile.cl/
            qr/\Aclarochile[.]blackberry[.]com\z/,
        ],
        'entel' => [
            # Entel; http://www.entel.cl/
            qr/\Aentelpcs[.]blackberry[.](?:com|net)\z/,
        ],
        'movistar' => [
            # movistar; http://www.movistar.cl/
            qr/\Amovistar[.]cl[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CL::Phone - Major phone provider's domains in Chile

=head1 SYNOPSIS

    use Sisimai::Group::CL::Phone;
    print Sisimai::Group::CL::Phone->find('clarochile.blackberry.com');    # claro

=head1 DESCRIPTION

Sisimai::Group::CL::Phone has a domain list of major cellular phone providers
and major smart phone providers in Chile.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
