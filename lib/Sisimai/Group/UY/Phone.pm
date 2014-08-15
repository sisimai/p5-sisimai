package Sisimai::Group::UY::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Uruguay
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'claro' => [
            # http://www.claro.com.uy/
            qr/\Aclarouy[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # Movistar; http://www.movistar.com.uy
            qr/\Asms[.]movistar[.]com[.]uy\z/,
            qr/\Amovistar[.]uy[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::UY::Phone - Major phone provider's domains in Uruguay

=head1 SYNOPSIS

    use Sisimai::Group::UY::Phone;
    print Sisimai::Group::UY::Phone->find('sms.movistar.com.uy');  # movistar

=head1 DESCRIPTION

Sisimai::Group::UY::Phone has a domain list of major cellular phone providers
and major smart phone providers in Uruguay.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
