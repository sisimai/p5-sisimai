package Sisimai::Group::AT::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Austria/Republik Osterreich
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'a1' => [
            # A1; http://www.a1.net/
            qr/\Amobileemail[.]a1[.]net\z/,
        ],
        'api4sms' => [
            # http://www.api4sms.net
            qr/\Amembers[.]api4sms[.]net\z/,
        ],
        'firmensms' => [
            # http://www.firmensms.at
            qr/\Asubdomain[.]firmensms[.]at\z/,
        ],
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.net/ http://t-mobile.at/
            qr/\Asms[.]t-mobile[.]at\z/,
            qr/\Ainstantemail[.]t-mobile[.]at\z/,
        ],
        'three' => [
            # 3; http://www.drei.at/
            qr/\Adrei[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AT::Phone - Major phone provider's domains in Austria

=head1 SYNOPSIS

    use Sisimai::Group::AT::Phone;
    print Sisimai::Group::AT::Phone->find('sms.t-mobile.at');  # t-mobile

=head1 DESCRIPTION

Sisimai::Group::AT::Phone has a domain list of major cellular phone providers
and major smart phone providers in Austria.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
