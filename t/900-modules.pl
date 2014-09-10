package Sisimai::Test::Modules;
sub list {
    my $v = [];
    my $f = [ qw|
        Address.pm
        ARF.pm
        Data.pm
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
            MSP/US/AmazonSES.pm
            MSP/US/Facebook.pm
            MSP/US/Google.pm
            MSP/US/SendGrid.pm
            MSP/US/Verizon.pm
        MTA.pm
            MTA/Courier.pm
            MTA/Domino.pm
            MTA/Exim.pm
            MTA/Exchange.pm
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
        RFC3464.pm
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

    push @$v, 'Sisimai.pm';
    for my $e ( @$f ) {
        push @$v, sprintf( "Sisimai/%s", $e );
    }
    return $v;
}
1;
