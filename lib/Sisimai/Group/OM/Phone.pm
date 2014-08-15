package Sisimai::Group::OM::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Sultanate of Oman
        'omantel' => [
            # Omantel; http://www.omantel.om/
            qr/\Aomanmobile[.]blackberry[.]com\z/,
        ],
        'nawras' => [
            # Nawras; http://www.nawras.om/
            qr/\Anawras[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::OM::Phone - Major phone provider's domains in Oman

=head1 SYNOPSIS

    use Sisimai::Group::OM::Phone;
    print Sisimai::Group::OM::Phone->find('nawras.blackberry.com');    # nawras

=head1 DESCRIPTION

Sisimai::Group::OM::Phone has a domain list of major cellular phone providers
and major smart phone providers in Oman.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
