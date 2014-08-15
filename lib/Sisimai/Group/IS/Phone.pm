package Sisimai::Group::IS::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Iceland
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'siminn' => [
            # Síminn; http://www.siminn.is
            qr/\Abox[.]is\z/,
            qr/\Asiminn[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.is/
            qr/\Asms[.]is\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IS::Phone - Major phone provider's domains in Iceland

=head1 SYNOPSIS

    use Sisimai::Group::IS::Phone;
    print Sisimai::Group::IS::Phone->find('sms.is');   # vodafone

=head1 DESCRIPTION

Sisimai::Group::IS::Phone has a domain list of major cellular phone providers
and major smart phone providers in Iceland.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
