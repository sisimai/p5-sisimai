package Sisimai::Group::PY::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Paraguay
        'claro' => [
            # Claro; http://www.claro.com.py/
            qr/\Aclaropy[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PY::Phone - Major phone provider's domains in Paraguay

=head1 SYNOPSIS

    use Sisimai::Group::PY::Phone;
    print Sisimai::Group::PY::Phone->find('claropy');    # claro

=head1 DESCRIPTION

Sisimai::Group::PY::Phone has a domain list of major cellular phone providers
and major smart phone providers in Paraguay.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
