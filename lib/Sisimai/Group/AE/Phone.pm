package Sisimai::Group::AE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in United Arab Emirates
        'du' => [
            # du; http://du.ae/
            qr/\Adu[.]blackberry[.]com\z/,
        ],
        'etisalat' => [
            # Etisalat; http://www.etisalat.ae/
            qr/\Aetisalat[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AE::Phone - Major phone provider's domains in United Arab Emirates

=head1 SYNOPSIS

    use Sisimai::Group::AE::Phone;
    print Sisimai::Group::AE::Phone->find('du.blackberry.com');    # du

=head1 DESCRIPTION

Sisimai::Group::AE::Phone has a domain list of major cellular phone providers
and major smart phone providers in United Arab Emirates.

=head1 CLASS METHODS

=head2 C<B<find( I<domain> )>>

C<domain()> returns a category name found by the domain name from domain list.

    print Sisimai::Group::AE::Phone->find('du.blackberry.com');    # du

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
