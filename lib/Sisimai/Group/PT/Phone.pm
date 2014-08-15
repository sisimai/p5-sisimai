package Sisimai::Group::PT::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Portugal/Portuguese Republic
        'optimus' => [
            # Optimus; http://optimus.pt/
            qr/\Aoptimus[.]blackberry[.]com\z/,
        ],
        'tmn' => [
            # TMN; http://www.tmn.pt/
            qr/\Atmn[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PT::Phone - Major phone provider's domains in Portugal

=head1 SYNOPSIS

    use Sisimai::Group::PT::Phone;
    print Sisimai::Group::PT::Phone->find('tmn.blackberry.com');   # tmn

=head1 DESCRIPTION

Sisimai::Group::PT::Phone has a domain list of major cellular phone providers
and major smart phone providers in Portugal.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
