package Sisimai::Group::IT::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Italian Republic/Repubblica Italiana
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'telecomit' => [
            # TIM, Telecom Italia; http://www.tim.it/home
            qr/\Atimnet[.]com\z/,
        ],
        'three' => [
            # 3 Italia; http://www.tre.it/
            qr/\Atreitalia[.]blackberry[.]com\z/,
        ],
        'tim' => [
            # TIM.it; http://www.tim.it/
            qr/\Atim[.]blackberry[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.com/
            qr/\Asms[.]vodafone[.]it\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IT::Phone - Major phone provider's domains in Italy

=head1 SYNOPSIS

    use Sisimai::Group::IT::Phone;
    print Sisimai::Group::IT::Phone->find('sms.vodafone.it');  # vodafone

=head1 DESCRIPTION

Sisimai::Group::IT::Phone has a domain list of major cellular phone providers
and major smart phone providers in Italy.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
