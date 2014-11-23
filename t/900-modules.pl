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
            MSP/JP/EZweb.pm
            MSP/JP/KDDI.pm
            MSP/US/AmazonSES.pm
            MSP/US/Aol.pm
            MSP/US/Facebook.pm
            MSP/US/Google.pm
            MSP/US/Outlook.pm
            MSP/US/SendGrid.pm
            MSP/US/Verizon.pm
            MSP/US/Yahoo.pm
        MTA.pm
            MTA/Activehunter.pm
            MTA/Courier.pm
            MTA/Domino.pm
            MTA/Exim.pm
            MTA/Exchange.pm
            MTA/IMailServer.pm
            MTA/InterScanMSS.pm
            MTA/MailFoundry.pm
            MTA/McAfee.pm
            MTA/MessagingServer.pm
            MTA/mFILTER.pm
            MTA/MXLogic.pm
            MTA/Notes.pm
            MTA/OpenSMTPD.pm
            MTA/Postfix.pm
            MTA/qmail.pm
            MTA/Sendmail.pm
            MTA/SurfControl.pm
            MTA/V5sendmail.pm
            MTA/X1.pm
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

    push @$v, 'Sisimai.pm';
    for my $e ( @$f ) {
        push @$v, sprintf( "Sisimai/%s", $e );
    }
    return $v;
}
1;
