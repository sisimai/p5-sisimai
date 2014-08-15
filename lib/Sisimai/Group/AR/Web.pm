package Sisimai::Group::AR::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Argentina/Argentine Republic
        'ciudad' => [
            # Ciudad.com; http://www.ciudad.com.ar/
            qr/\Aciudad[.]com[.]ar\z/,
        ],
        'uol' => [
            # UOL; http://www.uolmail.com.ar/
            qr/\Auolsinectis[.]com[.]ar\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AR::Web - Major web mail service provider's domains in Argentine

=head1 SYNOPSIS

    use Sisimai::Group::AR::Web;
    print Sisimai::Group::AR::Web->find('ciudad.com.ar');    # ciudad

=head1 DESCRIPTION

Sisimai::Group::AR::Web has a domain list of major web mail service providers
in Argentine.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
