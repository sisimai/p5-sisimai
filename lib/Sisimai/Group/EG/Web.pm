package Sisimai::Group::EG::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Egypt, The Middle East region
        'gawab' => [
            # http://www.gawab.com/
            # http://www.gawab.com/webfront/main.php?doc=moreDomains
            qr/\Agawab[.]com\z/,

            # Algeria
            qr/\A(?:algerie|oran)[.]cc\z/,
            qr/\A(?:blida[.]info|mascara[.]ws)\z/,
            qr/\Aoued[.](?:info|org)\z/,

            # Egypt
            qr/\A(?:alex4all[.]com|mansoura[.]tv)\z/,
            qr/\A(?:alexandria|aswan|banha|giza|ismailia|portsaid)[.]cc\z/,
            qr/\A(?:sharm|sinai|suez|tanta|zagazig)[.]cc\z/,

            # Jordan
            qr/\Airbid[.]ws\z/,
            qr/\A(?:amman|aqaba|jerash|karak|urdun|zarqa)[.]cc\z/,

            # Kuwait
            qr/\Asafat[.](?:biz|info|us|ws)\z/,
            qr/\A(?:kuwaiti[.]tv|salmiya[.]biz)\z/,

            # Lebanon
            qr/\A(?:baalbeck|hamra|lebanese)[.]cc\z/,
            qr/\Alubnan(?:cc|ws)\z/,

            # Morocco
            qr/\A(?:agadir|maghreb|marrakesh|meknes|nador|rabat|tangiers|tetouan)[.]cc\z/,
            qr/\Ajadida[.](?:cc|org)\z/,
            qr/\Aoujda[.](?:biz|cc)\z/,
        
            # Oman
            qr/\Amuscat[.](?:tv|ws)\z/,
            qr/\A(?:dhofar|gabes|ibra|salalah|seeb)[.]cc\z/,
            qr/\Aomani[.]ws\z/,
            
            # Palestine
            qr/\A(?:falasteen|nablus|quds|rafah|ramallah|yunus)[.]cc\z/,
            qr/\Ahebron[.]tv\z/,

            # Saudi Arabia
            qr/\A(?:ahsa|arar)[.]ws\z/,
            qr/\A(?:abha|albaha|alriyadh|buraydah|dhahran|jizan)[.]cc\z/,
            qr/\A(?:jouf|khobar|madinah|qassem|tabouk|tayef|yanbo)[.]cc\z/,

            # Sudan
            qr/\A(?:khartoum|omdurman|sudanese)[.]cc\z/,

            # Syria
            qr/\Ahasakah[.]com\z/,
            qr/\A(?:homs|latakia|siria)[.]cc\z/,
            qr/\Apalmyra[.](?:cc|ws)\z/,

            # Tunisia
            qr/\A(?:bizerte|gafsa|kairouan|nabeul|sousse|tunisian)[.]cc\z/,
            qr/\A(?:nabeul[.]info|sfax[.]ws)\z/,

            # United Arab Emirates
            qr/\Aajman[.](?:cc|us|ws)\z/,
            qr/\Afujairah[.](?:cc|us|ws)\z/,
            qr/\Akhaimah[.]cc\z/,

            # Yemen
            qr/\A(?:sanaa|yemeni)[.]cc\z/,

            # Bahrain, Cameroon, Djibouti, East Timor, Eritrea, Guinea, Iraq, Kyrgyzstan,
            qr/\A(?:bahraini|manama|cameroon|djibouti|timor|eritrea|guinea|najaf|kyrgyzstan)[.]cc\z/,

            # South Africa, Tajikistan, Zambia
            qr/\A(?:dominican|tajikistan|zambia)[.]cc\z/,

            # Pakistan
            qr/\Apakistani[.]ws\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::EG::Web - Major web mail service provider's domains in Egypt

=head1 SYNOPSIS

    use Sisimai::Group::EG::Web;
    print Sisimai::Group::EG::Web->find('gawab.com');    # gawab

=head1 DESCRIPTION

Sisimai::Group::EG::Web has a domain list of major web mail service providers
in Egypt.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
