package Sisimai::Group::IL::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in State of Israel
        'cellcom' => [
            # סלקום - דף הבית ; http://www.cellcom.co.il/
            qr/\Acellcom[.]blackberry[.]com\z/,
        ],
        'spikko' => [
            # Spikko; http://spikkosms.com/
            qr/\Aspikkosms[.]com\z/,
        ],
        'pelephone' => [
            # Pelephone; http://www.pelephone.co.il/
            qr/\Apelephone[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IL::Phone - Major phone provider's domains in Israel

=head1 SYNOPSIS

    use Sisimai::Group::IL::Phone;
    print Sisimai::Group::IL::Phone->find('spikkosms.com');    # spikko

=head1 DESCRIPTION

Sisimai::Group::IL::Phone has a domain list of major cellular phone providers
and major smart phone providers in Israel.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
