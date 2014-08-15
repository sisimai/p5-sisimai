package Sisimai::Group::HN::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Honduras
        'claro' => [
            # Claro; http://www.claro.com.hn/
            qr/\Aclarohn[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::HN::Phone - Major phone provider's domains in Honduras

=head1 SYNOPSIS

    use Sisimai::Group::HN::Phone;
    print Sisimai::Group::HN::Phone->find('clarohn.blackberry.com');   # claro

=head1 DESCRIPTION

Sisimai::Group::HN::Phone has a domain list of major cellular phone providers
and major smart phone providers in Honduras.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
