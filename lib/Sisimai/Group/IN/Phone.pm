package Sisimai::Group::IN::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in India
        'aircel' => [
            # Aircel; http://www.aircel.com/, phone-number@aircel.co.in
            qr/\Aaircel[.]co[.]in\z/,
            qr/\Aairsms[.]com\z/,
        ],
        'airtel' => [
            # Bharti Airtel; http://www.airtel.com/
            qr/\Aairtel(?:ap|chennai|kerala|kk|kol|mail|mobile)[.]com\z/,
            qr/\Aairtel[.]blackberry[.]com\z/,
        ],
        'celforce' => [
            # Gujarat Celforce / Fascel
            qr/\Acelforce[.]com\z/,
        ],
        'dehlihutch' => [
            # Delhi Hutch
            qr/\Adelhi[.]hutch[.]co[.]in\z/,
        ],
        'escotel' => [
            # Haryana Escotel
            qr/\Aescotelmobile[.]com\z/,
        ],
        'rpgcellular' => [
            # Chennai RPG Cellular
            qr/\Arpgmail[.]net\z/,
        ],
        'ideacellular' => [
            # !DEA; http://ideacellular.net:80/IDEA.portal
            qr/\Aideacellular[.]net\z/,
        ],
        'loopmobile' => [
            # Loop Mobile (Formerly BPL Mobile); http://www.loopmobile.in/
            qr/\Abplmobile[.]com\z/,
            qr/\Aloopmobile[.]co[.]in\z/,
        ],
        'vodafone' => [
            # Vodafone India; http://www.vodafone.in/
            qr/\Ahutch[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IN::Phone - Major phone provider's domains in India

=head1 SYNOPSIS

    use Sisimai::Group::IN::Phone;
    print Sisimai::Group::IN::Phone->find('aircel.co.in');    # aircel

=head1 DESCRIPTION

Sisimai::Group::IN::Phone has a domain list of major cellular phone providers
and major smart phone providers in India.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
