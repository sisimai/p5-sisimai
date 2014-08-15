package Sisimai::Group::RO::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Romania
        'cosmote' => [
            # COSMOTE: http://www.cosmote.ro/
            qr/\Acosmotero[.]?blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::RO::Phone - Major phone provider's domains in Romania

=head1 SYNOPSIS

    use Sisimai::Group::RO::Phone;
    print Sisimai::Group::RO::Phone->find('cosmotero.blackberry.com'); # cosmote

=head1 DESCRIPTION

Sisimai::Group::RO::Phone has a domain list of major cellular phone providers
and major smart phone providers in Romania.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
