use Test::More;
use Test::UsedModules;

my $f = [ qw|
    Address.pm
    ARF.pm
    Data.pm
        Group/Phone.pm
        Group/Web.pm
    ISO3166.pm
    MIME.pm
    Mail.pm
        Mail/Mbox.pm
        Mail/Maildir.pm
    Message.pm
    MDA.pm
    MSP.pm
        MSP/JP/Biglobe.pm
        MSP/JP/KDDI.pm
        MSP/US/Facebook.pm
        MSP/US/Google.pm
        MSP/US/Verizon.pm
    MTA.pm
        MTA/Courier.pm
        MTA/Exim.pm
        MTA/Exchange.pm
        MTA/Fallback.pm
        MTA/OpenSMTPD.pm
        MTA/Postfix.pm
        MTA/qmail.pm
        MTA/Sendmail.pm
    Reason.pm
        Reason/Blocked.pm
        Reason/ContentError.pm
        Reason/ExceedLimit.pm
        Reason/Expired.pm
        Reason/Filtered.pm
        Reason/HostUnknown.pm
        Reason/MailboxFull.pm
        Reason/MailerError.pm
        Reason/MesgTooBig.pm
        Reason/NotAccept.pm
        Reason/OnHold.pm
        Reason/Rejected.pm
        Reason/RelayingDenied.pm
        Reason/SecurityError.pm
        Reason/Suspend.pm
        Reason/SystemError.pm
        Reason/SystemFull.pm
        Reason/UserUnknown.pm
    RFC2606.pm
    RFC3463.pm
    RFC5322.pm
    Rhost.pm
        Rhost/GoogleApps.pm
    String.pm
    Time.pm
| ];

my $c = [ qw|
    AE AL AR AT AU AW BE BG BM BR BS CA CH CL CN CO CR CZ DE DK DO EC EG ES FR
    GR GT HK HN HR HU ID IE IL IN IR IS IT JM JP KE KR LB LK LU LV MA MD ME MK
    MO MU MX MY NG NI NL NO NP NZ OM PA PE PH PK PL PR PT PY RO RS RU SA SE SG
    SK SR SV TH TR TW UA UG UK US UY VE VN ZA|
];

for my $e ( @$f ) { 
    used_modules_ok( 'lib/Sisimai/'.$e );
}

for my $e ( @$c ) {
    used_modules_ok( 'lib/Sisimai/Group/'.$e.'/Web.pm' );
    used_modules_ok( 'lib/Sisimai/Group/'.$e.'/Phone.pm' );
}

used_modules_ok( 'lib/Sisimai.pm' );
done_testing;
