package Sisimai::Group::SE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Kingdom of Sweden/Konungariket Sverige
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'tele2' => [
            # TELE2; http://www.tele2.se/
            qr/\Asms[.]tele2[.]se\z/,
            qr/\Atele2se[.]blackberry[.]com\z/,
        ],
        'telenor' => [
            # Telenor Sverige; http://www.telenor.se/
            qr/\Atelenor-se[.]blackberry[.]com\z/,
        ],
        'three' => [
            # 3; http://tre.se/
            qr/\Atre[.]blackberry[.]com\z/, # ...?
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SE::Phone - Major phone provider's domains in Kingdom of Sweden

=head1 SYNOPSIS

    use Sisimai::Group::SE::Phone;
    print Sisimai::Group::SE::Phone->find('sms.tele2.se'); # tele2

=head1 DESCRIPTION

Sisimai::Group::SE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kingdom of Sweden.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
