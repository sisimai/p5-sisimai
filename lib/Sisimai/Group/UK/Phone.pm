package Sisimai::Group::UK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone and cellular phone domains in the United Kingdom
        '24x' => [
            # http://www.24x.com
            qr/\A24xgateway[.]com\z/,
        ],
        'aql' => [
            # aql; http://aql.com/
            qr/\Atext[.]aql[.]com\z/,   # http://aql.com/sms/email-to-sms/
        ],
        'bt' => [
            # BT; http://www.bt.com/
            qr/\Abt[.]blackberry[.]com\z/,
        ],
        'csoft' => [
            # Connection Software; https://www.csoft.co.uk
            qr/\Aitsarrived[.]net\z/,
        ],
        'esendex' => [
            # Esendex; http://www.esendex.co.uk
            qr/\Aechoemail[.]net\z/,
        ],
        'haysystems' => [
            # Hay Systems Ltd (HSL); http://www.haysystems.com/mobile-networks/hsl-femtocell/
            qr/\Asms[.]haysystems[.]com\z/,
        ],
        'mediaburst' => [
            # Mediaburst; http://www.mediaburst.co.uk
            qr/\Asms[.]mediaburst[.]co[.]uk\z/,
        ],
        'mycoolsms' => [
            # My-Cool-SMS
            qr/\Amy-cool-sms[.]com\z/,
        ],
        'o2' => [
            # O2 (officially Telefonica O2 UK) ; http://www.o2.co.uk/
            qr/\Amobile[.]celloneusa[.]com\z/,  # 44number@
            qr/\Ammail[.]co[.]uk\z/,
            qr/\Ao2[.]co[.]uk\z/,
            qr/\Ao2imail[.]co[.]uk\z/,          # Cannot resolve ARR, MXRR
            qr/\Ao2email[.]co[.]uk\z/,
        ],
        'orange' => [
            # Orange U.K.; http://www.orange.co.uk/
            qr/\Aorange[.]net\z/,       # 0number@
        ],
        'sure' => [
            # Sure (Cable & Wireless) in Guernsey; http://www.surecw.com/
            qr/\Acwguernsey[.]blackberry[.]net\z/,
        ],
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.net/
            qr/\At-mobile[.]uk[.]net\z/,
            qr/\Ainstantemail[.]t-mobile[.]co[.]uk\z/,
        ],
        'tesco' => [
            # Tesco Mobile; http://www.tesco.com/mobilenetwork/
            qr/\Atesco[.]blackberry[.]com\z/,
        ],
        'three' => [
            # Three; http://www.three.co.uk/
            qr/\A3uk[.]blackberry[.]com\z/,
        ],
        'txtlocal' => [
            # Txtlocal; http://www.txtlocal.co.uk/
            qr/\Atxtlocal[.]co[.]uk\z/,
        ],
        'unimovil' => [
            # UniMﾃｳvil Corporation
            qr/\Aviawebsms[.]com\z/,
        ],
        'virgin' => [
            # Virgin Mobile; http://www.virginmobile.com/
            qr/\Avxtras[.]com\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.com/
            qr/\Avodafone[.]net\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::UK::Phone - Major phone provider's domains in The United Kingdom

=head1 SYNOPSIS

    use Sisimai::Group::UK::Phone;
    print Sisimai::Group::UK::Phone->find('vodafone.net');    # vodafone

=head1 DESCRIPTION

Sisimai::Group::UK::Phone has a domain list of major cellular phone providers
and major smart phone providers in The United Kingdom.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
