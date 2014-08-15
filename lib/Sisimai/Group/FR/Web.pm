package Sisimai::Group::FR::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in French Republic
        'sfr' => [
            # SFR; http://www.sfr.fr/
            qr/\A(?:cario|guideo)[.]fr\z/,
            qr/\A(?:mageos|waika9)[.]com\z/,
            qr/\Afnac[.]net\z/,
            qr/\Asfr[.]fr\z/,
        ],
        'voila' => [
            # http://www.voila.fr/
            qr/\Avoila[.]fr\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::FR::Web - Major web mail service provider's domains in France

=head1 SYNOPSIS

    use Sisimai::Group::FR::Web;
    print Sisimai::Group::FR::Web->find('sfr.fr');    # sfr

=head1 DESCRIPTION

Sisimai::Group::FR::Web has a domain list of major web mail service providers
in France.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
