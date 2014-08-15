package Sisimai::Group::LK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Democratic Socialist Republic of Sri Lanka
        'mobiltel' => [
            # Mobiltel; http://www.mobitel.lk/
            qr/\Asms[.]mobitel[.]lk\z/,
        ],
        'dialog' => [
            # Dialog; http://www.dialog.lk/
            qr/\Adialog[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::LK::Phone - Major phone provider's domains in Sri Lanka

=head1 SYNOPSIS

    use Sisimai::Group::LK::Phone;
    print Sisimai::Group::LK::Phone->find('sms.mobitel.lk');    # mobiltel

=head1 DESCRIPTION

Sisimai::Group::LK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Sri Lanka.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
