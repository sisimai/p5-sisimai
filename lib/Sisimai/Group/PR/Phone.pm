package Sisimai::Group::PR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Commonwealth of Puerto Rico
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'centennial' => [
            # Centennial Communications; http://www.centennialwireless.com/
            qr/\Acwemail[.]com\z/,
        ],
        'claro' => [
            qr/\Avtexto[.]com\z/,                       # Claro; http://www.americamovil.com/
            qr/\A(?:claro|vzw)pr[.]blackberry[.]com\z/, # Claro; http://www.claropr.com/
        ],
        'tracfone' => [
            # TracFone Wireless; http://www.tracfone.com/
            qr/\Amypixmessages[.]com\z/,    # Straight Talk
            qr/\Ammst5[.]tracfone[.]com\z/, # Direct
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PR::Phone - Major phone provider's domains in Puerto Rico

=head1 SYNOPSIS

    use Sisimai::Group::PR::Phone;
    print Sisimai::Group::PR::Phone->find('vtexto.com');    # claro

=head1 DESCRIPTION

Sisimai::Group::PR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Puerto Rico.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
