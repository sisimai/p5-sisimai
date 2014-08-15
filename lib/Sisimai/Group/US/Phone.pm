package Sisimai::Group::US::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in The United States of America
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'airfile' => [
            # Airfire Mobile
            qr/\Asms[.]airfiremobile[.]com\z/,
        ],
        'alaskacomm' => [
            # Alaska Communications; http://www.alaskacommunications.com/
            qr/\Amsg[.]acsalaska[.]com\z/,
        ],
        'alltel' => [
            # AllTel Wireless; http://www.alltel.com
            qr/\Atext[.]wireless[.]alltel[.]com\z/, # SMS
            qr/\Asms[.]alltelwireless[.]com\z/,     # SMS
            qr/\Amms[.]alltelwireless[.]com\z/,     # MMS
            qr/\Aalltel[.]blackberry[.]com\z/,      # Smart phone
        ],
        'att' => [
            # AT&T Wireless; http://wireless.att.com/home/
            qr/\A(?:txt|mms|page)[.]att[.]net\z/,   # SMS, MMS, AT&T Enterprise Paging
            qr/\Ammode[.]com\z/,                    # AT&T grandfathered customers
            qr/\Acingularme[.]com\z/,               # AT&T Mobility (Formerly Cingular)
            qr/\Amobile[.]mycingular[.]com\z/,
            qr/\Asms[.]smartmessagingsuite[.]com\z/,# AT&T Global Smart Messaging Suite
            qr/\Acingular[.]com\z/,                 # Cingular (Postpaid)
            qr/\Acingulartext[.]com\z/,             # Cingular (GoPhone prepaid)
            qr/\Apaging[.]acswireless[.]com\z/,     # Ameritech
            qr/\Abellsouth[.]cl\z/,                 # BellSouth
            qr/\Asms[.]edgewireless[.]com\z/,       # Edge Wireless; 
            qr/\A(?:att|mycingular)[.]blackberry[.](?:com|net)\z/, # Cingular Wireles -> AT&T Mobility
        ],
        'bluegrass' => [
            # Bluegrass Cellular; http://bluegrasscellular.com/
            qr/\Abluegrass[.]blackberry[.]com\z/,
        ],
        'bluesky' => [
            # Bluesky Communications/American Samoa, USA
            qr/\Apsms[.]bluesky[.]as\z/,
        ],
        'boostmobile' => [
            # Boost Mobile; http://www.boostmobile.com/
            qr/\Amyboostmobile[.]com\z/,
            qr/\Asms[.]myboostmobile[.]com\z/,
        ],
        'cbeyond' => [
            # Cbeyond; http://www.cbeyond.net/
            qr/\Acbeyond[.]blackberry[.]com\z/,
        ],
        'cellcomus' => [
            # Cellcom; http://www.cellcom.com
            qr/\Acellcom[.]quiktxt[.]com\z/,
            qr/\Acellcom[.]us[.]blackberry[.]com\z/,
        ],
        'cellularone' => [
            # Cellular One; http://www.cellularone.com/
            qr/\Amobile[.]celloneusa[.]com\z/,
            qr/\Adobsoncellular[.]blackberry[.]net\z/,
            qr/\Acellularone[.]blackberry[.](?:com|net)\z/,
        ],
        'cellularsouth' => [
            # Cellular South; http://www.cellularsouth.com/
            qr/\Acsouth1[.]com\z/,
            qr/\Acsouth1[.]blackberry[.]com\z/,
        ],
        'centennial' => [
            # Centennial Communications; http://www.centennialwireless.com/
            qr/\Acwemail[.]com\z/,
            qr/\Acentennial[.]blackberry[.]com\z/,
        ],
        'charitonvalley' => [
            # Chariton Valley Wireless; http://cvalley.net
            qr/\Asms[.]cvalley[.]net\z/,
        ],
        'chatmobility' => [
            # Chat Mobility; http://www.chatmobility.com/
            qr/\Amail[.]msgsender[.]com\z/,
        ],
        'cincinatibell' => [
            # Cincinnati Bell; http://www.cincinnatibell.com/
            qr/\A(?:mms[.])?gocbw[.]com\z/,     # MMS, SMS
            qr/\Acinbell[.]blackberry[.](?:com|net)\z/,
        ],
        'cleartalk' => [
            # CLEAR TALK Wireless; http://www.cleartalk.net
            qr/\Asms[.]cleartalk[.]us\z/,
        ],
        'cricket' => [
            # Cricket Wireless; http://www.mycricket.com/
            qr/\A(?:mms|sms)[.]mycricket[.]com\z/,  # MMS, SMS
        ],
        'cspire' => [
            # C Spire Wireless; http://www.cspire.com
            qr/\Acspire1[.]com\z/,
        ],
        'earthlink' => [
            # EarthLink; http://www.earthlink.net/
            qr/\Aearthlink[.]blackberry[.]net\z/,
        ],
        'edgewireless' => [
            # Edge Wireless; http://www.edgewireless.com/ ...? 
            # AT&T
            qr/\Aedgewireless[.]blackberry[.]com\z/,
        ],
        'elementmobile' => [
            # Element Mobile; http://www.elementmobile.com
            qr/\Asms[.]elementmobile[.]net\z/,
        ],
        'gci' => [
            # GCI, General Communication Inc.; http://www.gci.com/
            qr/\Amobile[.]gci[.]net\z/,
        ],
        'gsc' => [
            # Golden State Cellular; http://www.goldenstatecellular.com/
            qr/\Agscsms[.]com\z/,
        ],
        'helio' => [
            # Helio; http://www.heliomag.com/
            qr/\Amyhelio[.]com\z/,
        ],
        'iwireless' => [
            # i wireless; http://www.iwireless.com/
            qr/\Aiwspcs[.]net\z/,       # T-Mobile, <phone-number>iws@
            qr/\Aiwirelesshometext[.]com/,  # Sprint PCS
        ],
        'kajeet' => [
            # Kajeet; http://www.kajeet.com/
            qr/\Amobile[.]kajeet[.]net\z/,
        ],
        'longlines' => [
            # LongLines
            qr/\Atext[.]longlines[.]com\z/,
        ],
        'metropcs' => [
            # MetroPCS Communications, Inc.; http://www.metropcs.com/
            qr/\Amymetropcs[.]com\z/,
            qr/\Ametropcs[.]blackberry[.]com\z/,
        ],
        'nextech' => [
            # Nextech; http://www.nex-techwireless.com/
            qr/\Asms[.]nextechwireless[.]com\z/,
        ],
        'ntelos' => [
            # nTelos; http://www.ntelos.com/
            qr/\Antelos[.]blackberry[.]com\z/,
        ],
        'pioneercellular' => [
            # Pioneer Cellular; https://www.wirelesspioneer.com/
            qr/\Azsend[.]com\z/,        # 9-digit-number@
        ],
        'pocketcomm' => [
            # Pocket Communications; http://www.pocket.com/
            qr/\Asms[.]pocket[.]com\z/,
        ],
        'pti' => [
            # IT&E(GUAM,CNMI); http://www.ite.net/
            qr/\Apti[.]blackberry[.]com\z/,
        ],
        'qwest' => [
            # Qwest Wireless; http://www.qwest.com/wireless
            # Qwest Wireless is a Mobile Virtual Network Operator (MVNO)
            # that currently operates on Verizon Wireless' CDMA network. 
            qr/\Aqwestmp[.]com\z/,
        ],
        'southcentralcomm' => [
            # South Central Communications; http://www.southcentralcommunications.net/
            qr/\Arinasms[.]com\z/,      # SMS
        ],
        'southernlinc' => [
            # Southernlinc Wireless; http://www.southernlinc.com
            qr/\Apage[.]southernlinc[.]com\z/,
            qr/\Asouthernlinc[.]blackberry[.]com\z/,
        ],
        'sprint' => [
            # Sprint Nextel Corporation; http://sprint.com/
            qr/\Amessaging[.]sprintpcs[.]com\z/,        # SMS
            qr/\Apm[.]sprint[.]com\z/,                  # MMS
            qr/\A(page|messaging)[.]nextel[.]com\z/,    # Rich messaging, SMS
            qr/\Ahawaii[.]sprintpcs[.]com\z/,           # Hawaiian Telcom Wireless
            qr/\A(?:nextel|sprint)[.]blackberry[.](?:com|net)\z/,
        ],
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.net/
            qr/\Atmomail[.]net\z/,  # MMS, number can and by default properly begins with "1" (the US country code)
            qr/\Asmtext.com\z/,     # Simple Mobile; T-Mobile USA MVNO.
            qr/\Atmo[.]blackberry[.]net\z/,
        ],
        'tcs' => [
            # TeleCommunication Systems; http://www.telecomsys.com/
            qr/\Atcs[.]blackberry[.]net\z/,
        ],
        'teleflip' => [
            # Teleflip; 
            qr/\Ateleflip[.]com\z/,
        ],
        'ting' => [
            # Ting
            qr/message[.]ting[.]com\z/,
        ],
        'tracfone' => [
            # TracFone Wireless; http://www.tracfone.com/
            qr/\Amypixmessages[.]com\z/,    # Straight Talk
            qr/\Ammst5[.]tracfone[.]com\z/, # Direct
        ],
        'usamobility' => [
            # USA Mobility; http://www.usamobility.com
            qr/\Ausamobility[.]net\z/,
        ],
        'uscellular' => [
            # U.S. Cellular, http://www.uscc.com/
            qr/\A(?:email|mms)[.]uscc[.]net\z/, # SMS,MMS
            qr/\Auscellular[.]blackberry[.]com\z/,
        ],
        'verizon' => [
            # Verizon Wireless; http://www.verizonwireless.com/
            # Merger with Alltel was completed in November 2009
            qr/\Amessage[.]alltel[.]com\z/,     # SMS & MMS
            qr/\A(?:vtext|vzwpix)[.]com\z/,     # SMS,MMS
            qr/\Atext[.]wireless[.]alltel[.]com\z/,
            qr/\Amms[.]alltel[.]net\z/,         # MMS
            qr/\Avzw[.]blackberry[.]net\z/,
            qr/\Averizon[.]net\z/,
        ],
        'viaero' => [
            # Viaero Wireless; http://www.viaero.com/
            qr/\A(?:viaerosms|mmsviaero)[.]com\z/,  # SMS,MMS
        ],
        'virgin' => [
            # Virgin Mobile; http://www.virginmobile.com/
            # http://www.virgin.com/gateways/mobile/
            qr/\A(?:vmobl|vmpix)[.]com\z/,      # SMS,MMS
        ],
        'voyagermobile' => [
            # Voyager Mobile; http://www.voyagermobile.com
            qr/\Atext[.]voyagermobile[.]com\z/,
        ],
        'westcentral' => [
            # West Central Wireless; http://www.westcentral.com
            qr/\Asms[.]wcc[.]net\z/,
        ],
        'xitcomm' => [
            # XIT Communications; http://www.xit.net
            qr/\Asms[.]xit[.]net\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::US::Phone - Major phone provider's domains in The United States
of America

=head1 SYNOPSIS

    use Sisimai::Group::US::Phone;
    print Sisimai::Group::US::Phone->find('verizon.net');  # verizon 

=head1 DESCRIPTION

Sisimai::Group::US::Phone has a domain list of major cellular phone providers
and major smart phone providers in The United States of America.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
