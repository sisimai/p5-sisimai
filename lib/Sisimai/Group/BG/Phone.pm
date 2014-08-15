package Sisimai::Group::BG::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Bulgaria
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'globul' => [
            # GLOBUL; http://www.globul.bg/
            qr/\Asms[.]globul[.]bg\z/,
            qr/\Aglobul[.]blackberry[.]com\z/,
        ],
        'mtel' => [
            # Mobiltel; http://www.mtel.bg/
            qr/\Asms[.]mtel[.]net\z/,
            qr/\Amtel[.]blackberry[.]com\z/,
        ],
        'vivacom' => [
            # Vivacom; http://www.vivacom.bg/
            qr/\Asms[.]vivacom[.]bg\z/, # (country-code-Vivacom-area-code-number@)
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BG::Phone - Major phone provider's domains in Bulgaria

=head1 SYNOPSIS

    use Sisimai::Group::BG::Phone;
    print Sisimai::Group::BG::Phone->find('sms.globul.bg');    # globul

=head1 DESCRIPTION

Sisimai::Group::BG::Phone has a domain list of major cellular phone providers
and major smart phone providers in Bulgaria.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
