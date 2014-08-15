package Sisimai::Group::AU::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Commonwealth of Australia
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'itcompany' => [
            # All Australian Mobile Networks 
            qr/\Asms[.]itcompany[.]com[.]au\z/,
        ],
        'optus' => [
            # SingTel Optus Pty Limited; http://www.optus.com.au/
            qr/\Aoptus[.]blackberry[.]com\z/,
        ],
        'smsbroadcast' => [
            # SMS Broadcast;  https://www.smsbroadcast.com.au
            qr/\Asend[.]smsbroadcast[.]com[.]au\z/,
        ],
        'smscentral' => [
            # SMS Central; http://www.smscentral.com.au
            qr/\Asms[.]smscentral[.]com[.]au\z/,
        ],
        'smspup' => [
            # SMSPUP; http://smspup.com
            qr/\Asmspup[.]com\z/,
        ],
        't-mobile' => [
            # SingTel Optus Pty Limited; http://www.optus.com.au/
            qr/\Aoptusmobile[.]com[.]au\z/,
        ],
        'telstra' => [
            # Telstra; http://www.telstra.com.au/
            qr/\A(?:sms[.])?tim[.]telstra[.]com\z/,
            qr/\Atelstra[.]blackberry[.]com\z/,
        ],
        'three' => [
            # Three Mobile Australia; http://www.three.com.au/
            qr/\Athree[.]blackberry[.]com\z/,
        ],
        'utbox' => [
            # UTBox; http://www.utbox.net
            qr/\Asms[.]utbox[.]net\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AU::Phone - Major phone provider's domains in Australia

=head1 SYNOPSIS

    use Sisimai::Group::AU::Phone;
    print Sisimai::Group::AU::Phone->find('sms.utbox.net');    # utbox

=head1 DESCRIPTION

Sisimai::Group::AU::Phone has a domain list of major cellular phone providers
and major smart phone providers in Australia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
