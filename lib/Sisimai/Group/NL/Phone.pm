package Sisimai::Group::NL::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Kingdom of the Netherlands/Koninkrijk der Nederlanden
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'kpn' => [
            # KPN; http://www.kpn.com/
            qr/\Akpn[.]blackberry[.]com\z/,
        ],
        'motricity' => [
            # Motricity; http://www.gin.nl/
            qr/\Agin[.]nl\z/,
        ],
        't-mobile' => [
            qr/\Asms[.]orange[.]nl\z/,              # Orange -> T-Mobile; http://www.online.nl/
            qr/\Ainstantemail[.]t-mobile[.]nl\z/,   # T-Mobile; http://www.t-mobile.nl/
        ],
        'uts' => [
            # UTS/Netherlands Antilles; http://www.uts.an/
            qr/\Auts[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NL::Phone - Major phone provider's domains in Netherlands

=head1 SYNOPSIS

    use Sisimai::Group::NL::Phone;
    print Sisimai::Group::NL::Phone->find('sms.prange.nl');    # t-mobile

=head1 DESCRIPTION

Sisimai::Group::NL::Phone has a domain list of major cellular phone providers
and major smart phone providers in Netherlands.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
