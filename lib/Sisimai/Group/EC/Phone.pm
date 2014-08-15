package Sisimai::Group::EC::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Ecuador
        'claro' => [
            # Claro; http://www.porta.net/
            # By the end of February 2011, the name Porta will be switched to Claro
            qr/\Aporta[.]blackberry[.]com\z/,
        ],
        'movistar' => [
            # movistar; http://movistar.com.ec/
            qr/\Amovistar[.]ec[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::EC::Phone - Major phone provider's domains in Ecuador

=head1 SYNOPSIS

    use Sisimai::Group::EC::Phone;
    print Sisimai::Group::EC::Phone->find('porta.blackberry.com'); # claro

=head1 DESCRIPTION

Sisimai::Group::EC::Phone has a domain list of major cellular phone providers
and major smart phone providers in Ecuador.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
