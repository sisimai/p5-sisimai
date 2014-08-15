package Sisimai::Group::KE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Kenya/Jamhuri ya Kenya
        'airtel' => [
            # Airtel in Kenya; http://africa.airtel.com/kenya/
            qr/\Aairtel[.]blackberry[.]com\z/,
        ],
        'safaricom' => [
            # Safaricom Ltd.; http://www.safaricom.co.ke/
            qr/\Asafaricom[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::KE::Phone - Major phone provider's domains in Kenya

=head1 SYNOPSIS

    use Sisimai::Group::KE::Phone;
    print Sisimai::Group::KE::Phone->find('airtel.blackberry.com');    # airtel

=head1 DESCRIPTION

Sisimai::Group::KE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kenya.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
