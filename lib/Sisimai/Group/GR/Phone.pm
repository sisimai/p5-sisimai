package Sisimai::Group::GR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Greece/Hellenic Republic
        'cosmote' => [
            # COSMOTE: http://www.cosmote.gr/
            qr/\Acosmote[.]?gr[.]blackberry[.]com\z/,
        ],
        'wind' => [
            # Wind; http://www.wind.com.gr/
            qr/\Awindgr[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::GR::Phone - Major phone provider's domains in Greece

=head1 SYNOPSIS

    use Sisimai::Group::GR::Phone;
    print Sisimai::Group::GR::Phone->find('windgr.blackberry.com');    # wind

=head1 DESCRIPTION

Sisimai::Group::GR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Greece.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
