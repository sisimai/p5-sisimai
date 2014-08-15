package Sisimai::Group::BR::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Brazil
        'bol' => [
            # BOL - O e-mail gratis do Brasil
            # http://www.bol.uol.com.br/
            qr/\Abol[.]com[.]br\z/,
        ],
        'uol' => [
            # Universo Online; http://www.uol.com.br/
            qr/\Auol[.]com[.](?:ar|br)\z/,
        ],
        'zipmail' => [
            # Zipmail; http://zipmail.uol.com.br/
            qr/\Azipmail[.]com[.]br\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BR::Web - Major web mail service provider's domains in Brazil

=head1 SYNOPSIS

    use Sisimai::Group::BR::Web;
    print Sisimai::Group::BR::Web->find('bol.com.br');    # bol

=head1 DESCRIPTION

Sisimai::Group::BR::Web has a domain list of major web mail service providers
in Brazil.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
