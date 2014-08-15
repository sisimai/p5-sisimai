package Sisimai::Group::HK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Hong Kong
        'accessyou' => [
            # http://www.accessyou.com
            qr/\Amessaging[.]accessyou[.]com\z/,
        ],
        'hkcsl' => [
            # Hong Kong CSL Limited/香港移動通訊有限公司; 
            # http://www.hkcsl.com/en/index/index.jsp
            qr/\Amgw[.]mmsc1[.]hkcsl[.]com\z/,
            qr/\Acsl[.]blackberry[.]com\z/,
        ],
        'pccw' => [
            # PCCW Limited; http://www.pccw.com/eng//
            qr/\Apccwmobile[.]blackberry[.]com\z/,
        ],
        'smartone' => [
            # SmarTone Mobile Communications Limited; http://www.smartone.com.hk/
            # StarTone-Vodafone
            qr/\Asmartone[.]blackberry[.]com\z/,
        ],
        'three' => [
            # Three.com.hk; http://www.three.com.hk/
            qr/\Athreehk[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::HK::Phone - Major phone provider's domains in Hong Kong

=head1 SYNOPSIS

    use Sisimai::Group::HK::Phone;
    print Sisimai::Group::HK::Phone->find('csl.blackberry.com');   # csl

=head1 DESCRIPTION

Sisimai::Group::HK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Hong Kong.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
