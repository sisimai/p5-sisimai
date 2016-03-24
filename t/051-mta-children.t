use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $DebugOnlyTo = '';
my $MethodNames = {
    'class' => [ 'description', 'headerlist', 'scan', 'pattern', 'DELIVERYSTATUS' ],
    'object' => [],
};
my $MTAChildren = {
    'Activehunter' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'ApacheJames' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'Courier' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/filtered/ },
        '03' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '04' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/hostunknown/ },
    },
    'Domino' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
    },
    'Exchange' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
    },
    'Exim' => {
        '01' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/blocked/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/securityerror/ },
        '04' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/blocked/ },
        '05' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '07' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '08' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '09' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '10' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/suspend/ },
        '11' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/ },
        '12' => { 'status' => qr/\A[45][.]0[.]\d+\z/, 'reason' => qr/(?:hostunknown|expired|undefined)/ },
        '13' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/(?:onhold|undefined|mailererror)/ },
        '14' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '15' => { 'status' => qr/\A5[.]4[.]3\z/, 'reason' => qr/systemerror/ },
        '16' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/systemerror/ },
        '17' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '18' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '19' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/ },
        '20' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/(?:expired|systemerror)/ },
        '21' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '23' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '24' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '25' => { 'status' => qr/\A4[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '26' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/mailererror/ },
        '27' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/blocked/ },
        '28' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailererror/ },
        '29' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/blocked/ },
    },
    'IMailServer' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/ },
    },
    'InterScanMSS' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    },
    'MailFoundry' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/mailboxfull/ },
    },
    'MailMarshalSMTP' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    },
    'McAfee' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    },
    'MessagingServer' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]2[.]0\z/, 'reason' => qr/mailboxfull/ },
        '03' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/filtered/ },
        '04' => { 'status' => qr/\A5[.]2[.]2\z/, 'reason' => qr/mailboxfull/ },
        '05' => { 'status' => qr/\A5[.]4[.]4\z/, 'reason' => qr/hostunknown/ },
        '06' => { 'status' => qr/\A5[.]2[.]1\z/, 'reason' => qr/filtered/ },
        '07' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/expired/ },
    },
    'mFILTER' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'MXLogic' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'Notes' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/ },
    },
    'OpenSMTPD' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.][12][.][12]\z/, 'reason' => qr/(?:userunknown|mailboxfull)/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
    },
    'Postfix' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/mailererror/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/(?:filtered|userunknown)/ },
        '03' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/filtered/ },
        '04' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '05' => { 'status' => qr/\A4[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A5[.]4[.]4\z/, 'reason' => qr/hostunknown/ },
        '07' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '08' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/expired/ },
        '09' => { 'status' => qr/\A4[.]3[.]2\z/, 'reason' => qr/toomanyconn/ },
        '10' => { 'status' => qr/\A5[.]1[.]8\z/, 'reason' => qr/rejected/ },
        '11' => { 'status' => qr/\A5[.]1[.]8\z/, 'reason' => qr/rejected/ },
        '12' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '13' => { 'status' => qr/\A5[.]2[.][12]\z/, 'reason' => qr/(?:userunknown|mailboxfull)/ },
        '14' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '15' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/expired/ },
        '16' => { 'status' => qr/\A5[.]1[.]6\z/, 'reason' => qr/hasmoved/ },
        '17' => { 'status' => qr/\A5[.]4[.]4\z/, 'reason' => qr/networkerror/ },
        '18' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/norelaying/ },
        '19' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/blocked/ },
        '20' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/ },
        '21' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/ },
    },
    'qmail' => {
        '01' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/(?:userunknown|filtered)/ },
        '03' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/rejected/ },
        '04' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/blocked/ },
        '05' => { 'status' => qr/\A4[.]4[.]3\z/, 'reason' => qr/systemerror/ },
        '06' => { 'status' => qr/\A4[.]2[.]2\z/, 'reason' => qr/mailboxfull/ },
        '07' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/networkerror/ },
        '08' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '09' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/ },
    },
    'Sendmail' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/(?:userunknown|filtered)/ },
        '03' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]1[.]8\z/, 'reason' => qr/rejected/ },
        '05' => { 'status' => qr/\A5[.]2[.]3\z/, 'reason' => qr/exceedlimit/ },
        '06' => { 'status' => qr/\A5[.]6[.]9\z/, 'reason' => qr/contenterror/ },
        '07' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/norelaying/ },
        '08' => { 'status' => qr/\A4[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '09' => { 'status' => qr/\A5[.]7[.]9\z/, 'reason' => qr/securityerror/ },
        '10' => { 'status' => qr/\A4[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '11' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/expired/ },
        '12' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/expired/ },
        '13' => { 'status' => qr/\A5[.]3[.]0\z/, 'reason' => qr/systemerror/ },
        '14' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '15' => { 'status' => qr/\A5[.]1[.]2\z/, 'reason' => qr/hostunknown/ },
        '16' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/blocked/ },
        '17' => { 'status' => qr/\A5[.]1[.]6\z/, 'reason' => qr/hasmoved/ },
        '18' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/mailererror/ },
        '19' => { 'status' => qr/\A5[.]2[.]0\z/, 'reason' => qr/filtered/ },
        '20' => { 'status' => qr/\A5[.]4[.]6\z/, 'reason' => qr/networkerror/ },
        '21' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/blocked/ },
        '22' => { 'status' => qr/\A5[.]1[.]6\z/, 'reason' => qr/hasmoved/ },
        '23' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/spamdetected/ },
        '24' => { 'status' => qr/\A5[.]1[.]2\z/, 'reason' => qr/hostunknown/ },
        '25' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '26' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '27' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/filtered/ },
        '28' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '29' => { 'status' => qr/\A4[.]5[.]0\z/, 'reason' => qr/expired/ },
        '30' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/expired/ },
        '31' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/securityerror/ },
        '32' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '33' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '34' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/securityerror/ },
        '35' => { 'status' => qr/\A5[.]7[.]13\z/, 'reason' => qr/suspend/ },
        '36' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '37' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '38' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/spamdetected/ },
    },
    'SurfControl' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/systemerror/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/systemerror/ },
    },
    'V5sendmail' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/(?:hostunknown|blocked|userunknown)/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/norelaying/ },
        '07' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/(?:hostunknown|blocked|userunknown)/ },
    },
    'X1' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'X2' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/(?:filtered|suspend)/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/suspend/ },
    },
    'X3' => {
        '01' => { 'status' => qr/\A5[.]3[.]0\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '03' => { 'status' => qr/\A5[.]3[.]0\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/ },
    },
    'X4' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '03' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '07' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/networkerror/ },
    },
    'X5' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    }
};

for my $x ( keys %$MTAChildren ) {
    # Check each MTA module
    my $M = 'Sisimai::MTA::'.$x;
    my $v = undef;
    my $n = 0;
    my $c = 0;
    my $d = 0;

    Module::Load::load( $M );
    use_ok $M;
    can_ok $M, @{ $MethodNames->{'class'} };

    MAKE_TEST: {
        $v = $M->description; ok $v, $x.'->description = '.$v;
        $v = $M->smtpagent;   ok $v, $x.'->smtpagent = '.$v;
        $v = $M->pattern;     ok keys %$v; isa_ok $v, 'HASH';

        $M->scan, undef, $M.'->scan = undef';

        PARSE_EACH_MAIL: for my $i ( 1 .. scalar keys %{ $MTAChildren->{ $x } } ) {
            # Open email in set-of-emails/ directory
            if( length $DebugOnlyTo ) {
                $c = 1;
                next unless $DebugOnlyTo eq sprintf( "%s-%02d", lc($x), $i );
            }

            my $emailfn = sprintf( "./set-of-emails/maildir/bsd/%s-%02d.eml", lc($x), $i );
            my $mailbox = Sisimai::Mail->new( $emailfn );

            $n = sprintf( "%02d", $i );
            next unless defined $mailbox;
            next unless $MTAChildren->{ $x }->{ $n };
            ok -f $emailfn, sprintf( "[%s] %s/email = %s", $n, $M,$emailfn );

            while( my $r = $mailbox->read ) {
                # Parse each email in set-of-emails/maildir/bsd directory
                my $p = undef;
                my $o = undef;
                my $d = 0;
                my $g = undef;

                $p = Sisimai::Message->new( 'data' => $r );
                isa_ok $p,         'Sisimai::Message';
                isa_ok $p->ds,     'ARRAY';
                isa_ok $p->header, 'HASH';
                isa_ok $p->rfc822, 'HASH';

                ok length $p->from,    sprintf( "[%s] %s->from = %s", $n, $M, $p->from );
                ok scalar @{ $p->ds }, sprintf( "[%s] %s/ds entries = %d", $n, $M, scalar @{ $p->ds } );

                for my $e ( @{ $p->ds } ) {
                    $d++;
                    $g = sprintf( "%02d-%02d", $n, $d );

                    for my $ee ( qw|recipient agent| ) {
                        # Length of each variable > 0
                        ok length $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $g, $x, $ee, $e->{ $ee } );
                    }

                    for my $ee ( qw|
                        date spec reason status command action alias rhost lhost 
                        diagnosis feedbacktype softbounce| ) {
                        # Each key should be exist
                        ok exists $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $g, $x, $ee, $e->{ $ee } );
                    }

                    # Check the value of the following variables
                    if( $x eq 'mFILTER' ) {
                        # mFILTER => m-FILTER
                        is $e->{'agent'}, 'm-FILTER', sprintf( "[%s] %s->agent = %s", $g, $x, $e->{'agent'} );

                    } elsif( $x eq 'X4' ) {
                        # X4 is qmail clone
                        like $e->{'agent'}, qr/(?:qmail|X4)/, sprintf( "[%s] %s->agent = %s", $g, $x, $e->{'agent'} );

                    } else {
                        # Other MTA modules
                        is $e->{'agent'}, $x, sprintf( "[%s] %s->agent = %s", $g, $x, $e->{'agent'} );
                    }

                    like   $e->{'recipient'}, qr/[0-9A-Za-z@-_.]+/, sprintf( "[%s] %s->recipient = %s", $g, $x, $e->{'recipient'} );
                    unlike $e->{'recipient'}, qr/[ ]/,              sprintf( "[%s] %s->recipient = %s", $g, $x, $e->{'recipient'} );
                    unlike $e->{'command'},   qr/[ ]/,              sprintf( "[%s] %s->command = %s", $g, $x, $e->{'command'} );

                    if( length $e->{'status'} ) {
                        # Check the value of "status"
                        like $e->{'status'}, qr/\A(?:[45][.]\d[.]\d+)\z/,
                            sprintf( "[%s] %s->status = %s", $g, $x, $e->{'status'} );
                    }

                    if( length $e->{'action'} ) {
                        # Check the value of "action"
                        like $e->{'action'}, qr/\A(?:fail.+|delayed|expired)\z/, 
                            sprintf( "[%s] %s->action = %s", $g, $x, $e->{'action'} );
                    }

                    for my $ee ( 'rhost', 'lhost' ) {
                        # Check rhost and lhost are valid hostname or not
                        next unless $e->{ $ee };
                        next if $x =~ m/\A(?:qmail|Exim|Exchange|X4)\z/;
                        like $e->{ $ee }, qr/\A(?:localhost|.+[.].+)\z/, sprintf( "[%s] %s->%s = %s", $g, $x, $ee, $e->{ $ee } );
                    }
                }


                $o = Sisimai::Data->make( 'data' => $p );
                isa_ok $o, 'ARRAY';
                ok scalar @$o, sprintf( "%s/entry = %s", $M, scalar @$o );

                for my $e ( @$o ) {
                    # Check each accessor
                    isa_ok $e,            'Sisimai::Data';
                    isa_ok $e->timestamp, 'Sisimai::Time';
                    isa_ok $e->addresser, 'Sisimai::Address';
                    isa_ok $e->recipient, 'Sisimai::Address';

                    ok defined $e->replycode,      sprintf( "[%s] %s->replycode = %s", $g, $x, $e->replycode );
                    ok defined $e->subject,        sprintf( "[%s] %s->subject = ...", $g, $x );
                    ok defined $e->smtpcommand,    sprintf( "[%s] %s->smtpcommand = %s", $g, $x, $e->smtpcommand );
                    ok defined $e->diagnosticcode, sprintf( "[%s] %s->diagnosticcode = %s", $g, $x, $e->diagnosticcode );
                    ok defined $e->diagnostictype, sprintf( "[%s] %s->diagnostictype = %s", $g, $x, $e->diagnostictype );
                    ok length  $e->deliverystatus, sprintf( "[%s] %s->deliverystatus = %s", $g, $x, $e->deliverystatus );
                    ok length  $e->token,          sprintf( "[%s] %s->token = %s", $g, $x, $e->token );
                    ok length  $e->smtpagent,      sprintf( "[%s] %s->smtpagent = %s", $g, $x, $e->smtpagent );
                    ok length  $e->timezoneoffset, sprintf( "[%s] %s->timezoneoffset = %s", $g, $x, $e->timezoneoffset );

                    is $e->addresser->host, $e->senderdomain, sprintf( "[%s] %s->senderdomain = %s", $g, $x, $e->senderdomain );
                    is $e->recipient->host, $e->destination,  sprintf( "[%s] %s->destination = %s", $g, $x, $e->destination );

                    cmp_ok $e->softbounce, '>=', -1, sprintf( "[%s] %s->softbounce = %s", $g, $x, $e->softbounce );
                    cmp_ok $e->softbounce, '<=',  1, sprintf( "[%s] %s->softbounce = %s", $g, $x, $e->softbounce );

                    if( substr( $e->deliverystatus, 0, 1 ) == 4 ) {
                        # 4.x.x
                        is $e->softbounce, 1, sprintf( "[%s] %s->softbounce = %d", $g, $x, $e->softbounce );

                    } elsif( substr( $e->deliverystatus, 0, 1 ) == 5 ) {
                        # 5.x.x
                        is $e->softbounce, 0, sprintf( "[%s] %s->softbounce = %d", $g, $x, $e->softbounce );
                    } else {
                        # No deliverystatus
                        is $e->softbounce, -1, sprintf( "[%s] %s->softbounce = %d", $g, $x, $e->softbounce );
                    }

                    like $e->replycode,      qr/\A(?:[45]\d\d|)\z/,          sprintf( "[%s] %s->replycode = %s", $g, $x, $e->replycode );
                    like $e->timezoneoffset, qr/\A[-+]\d{4}\z/,              sprintf( "[%s] %s->timezoneoffset = %s", $g, $x, $e->timezoneoffset );
                    like $e->deliverystatus, $MTAChildren->{ $x }->{ $n }->{'status'}, sprintf( "[%s] %s->deliverystatus = %s", $g, $x, $e->deliverystatus );
                    like $e->reason,         $MTAChildren->{ $x }->{ $n }->{'reason'}, sprintf( "[%s] %s->reason = %s", $g, $x, $e->reason );
                    like $e->token,          qr/\A([0-9a-f]{40})\z/,         sprintf( "[%s] %s->token = %s", $g, $x, $e->token );

                    unlike $e->deliverystatus,qr/[ \r]/, sprintf( "[%s] %s->deliverystatus = %s", $g, $x, $e->deliverystatus );
                    unlike $e->diagnostictype,qr/[ \r]/, sprintf( "[%s] %s->diagnostictype = %s", $g, $x, $e->diagnostictype );
                    unlike $e->smtpcommand,   qr/[ \r]/, sprintf( "[%s] %s->smtpcommand = %s", $g, $x, $e->smtpcommand );

                    unlike $e->lhost,     qr/[ \r]/, sprintf( "[%s] %s->lhost = %s", $g, $x, $e->lhost );
                    unlike $e->rhost,     qr/[ \r]/, sprintf( "[%s] %s->rhost = %s", $g, $x, $e->rhost );
                    unlike $e->alias,     qr/[ \r]/, sprintf( "[%s] %s->alias = %s", $g, $x, $e->alias );
                    unlike $e->listid,    qr/[ \r]/, sprintf( "[%s] %s->listid = %s", $g, $x, $e->listid );
                    unlike $e->action,    qr/[ \r]/, sprintf( "[%s] %s->action = %s", $g, $x, $e->action );
                    unlike $e->messageid, qr/[ \r]/, sprintf( "[%s] %s->messageid = %s", $g, $x, $e->messageid );

                    unlike $e->addresser->user, qr/[ \r]/, sprintf( "[%s] %s->addresser->user = %s", $g, $x, $e->addresser->user );
                    unlike $e->addresser->host, qr/[ \r]/, sprintf( "[%s] %s->addresser->host = %s", $g, $x, $e->addresser->host );
                    unlike $e->addresser->verp, qr/[ \r]/, sprintf( "[%s] %s->addresser->verp = %s", $g, $x, $e->addresser->verp );
                    unlike $e->addresser->alias,qr/[ \r]/, sprintf( "[%s] %s->addresser->alias = %s", $g, $x, $e->addresser->alias );

                    unlike $e->recipient->user, qr/[ \r]/, sprintf( "[%s] %s->recipient->user = %s", $g, $x, $e->recipient->user );
                    unlike $e->recipient->host, qr/[ \r]/, sprintf( "[%s] %s->recipient->host = %s", $g, $x, $e->recipient->host );
                    unlike $e->recipient->verp, qr/[ \r]/, sprintf( "[%s] %s->recipient->verp = %s", $g, $x, $e->recipient->verp );
                    unlike $e->recipient->alias,qr/[ \r]/, sprintf( "[%s] %s->recipient->alias = %s", $g, $x, $e->recipient->alias );
                }
                $c++;
            }
        }
        ok $c, $M.'/the number of emails = '.$c;
    }
}


done_testing;
