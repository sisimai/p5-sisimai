package Sisimai::Group::NP::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Federal Democratic Republic of Nepal
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'ncell' => [
            # Ncell Private Ltd.; http://www.ncell.com.np/
            # Previously Mero Mobile
            qr/\Asms[.]spicenepal[.]com\z/,
            qr/\Asms[.]ncell[.]com[.]np\z/,

            # Ncell Private Ltd.; http://www.ncell.com.np/
            #  % dig mx ncell.blackberry.com +short
            #    10 mx02.bis7.eu.blackberry.com.
            #    10 mx03.bis7.eu.blackberry.com.
            #    10 mx04.bis7.eu.blackberry.com.
            #    10 mx01.bis7.eu.blackberry.com.
            # 
            # eu ?
            qr/\Ancell[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NP::Phone - Major phone provider's domains in Nepal

=head1 SYNOPSIS

    use Sisimai::Group::NP::Phone;
    print Sisimai::Group::NP::Phone->find('sms.ncell.com.np'); # ncell

=head1 DESCRIPTION

Sisimai::Group::NP::Phone has a domain list of major cellular phone providers
and major smart phone providers in Nepal.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
