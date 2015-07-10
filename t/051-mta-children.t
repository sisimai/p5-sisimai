use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $MethodNames = {
    'class' => [ 
        'version', 'description', 'headerlist', 'scan',
        'SMTPCOMMAND', 'DELIVERYSTATUS', 'RFC822HEADERS',
    ],
    'object' => [],
};
my $R = {
    'Sendmail' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/(?:userunknown|filtered)/ },
        '03' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]1[.]8\z/, 'reason' => qr/rejected/ },
        '05' => { 'status' => qr/\A5[.]2[.]3\z/, 'reason' => qr/exceedlimit/ },
        '06' => { 'status' => qr/\A5[.]6[.]9\z/, 'reason' => qr/contenterror/ },
        '07' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/norelaying/ },
        '08' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/blocked/ },
        '09' => { 'status' => qr/\A5[.]7[.]9\z/, 'reason' => qr/securityerror/ },
        '10' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/blocked/ },
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
    'Exim' => {
        '01' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/blocked/ },
        '02' => { 'status' => qr/\A5[.][12][.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/securityerror/ },
        '04' => { 'status' => qr/\A5[.]7[.]0\z/, 'reason' => qr/blocked/ },
        '05' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '07' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '08' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '09' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '10' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/suspend/ },
        '11' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/ },
    },
    'Courier' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/filtered/ },
        '03' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/blocked/ },
        '04' => { 'status' => qr/\A5[.]0[.]0\z/, 'reason' => qr/hostunknown/ },
    },
    'OpenSMTPD' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.][12][.][12]\z/, 'reason' => qr/(?:userunknown|mailboxfull)/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
    },
    'Exchange' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
    },
    'Domino' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
    },
    'Notes' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
    },
    'McAfee' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    },
    'MXLogic' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'MailFoundry' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/mailboxfull/ },
    },
    'IMailServer' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/userunknown/ },
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/ },
    },
    'mFILTER' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'Activehunter' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
    },
    'InterScanMSS' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
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
    'MessagingServer' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]2[.]0\z/, 'reason' => qr/mailboxfull/ },
        '03' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/filtered/ },
        '04' => { 'status' => qr/\A5[.]2[.]2\z/, 'reason' => qr/mailboxfull/ },
        '05' => { 'status' => qr/\A5[.]4[.]4\z/, 'reason' => qr/hostunknown/ },
        '06' => { 'status' => qr/\A5[.]2[.]1\z/, 'reason' => qr/filtered/ },
        '07' => { 'status' => qr/\A4[.]4[.]7\z/, 'reason' => qr/expired/ },
    },
    'MailMarshalSMTP' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
    },
    'ApacheJames' => {
        '01' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
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
        '04' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '05' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/ },
        '06' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/ },
        '07' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/networkerror/ },
    },
};

for my $x ( keys %$R ) {
    # Check each MTA module
    my $M = 'Sisimai::MTA::'.$x;
    my $v = undef;
    my $n = 0;
    my $c = 0;

    Module::Load::load( $M );
    use_ok $M;
    can_ok $M, @{ $MethodNames->{'class'} };

    MAKE_TEST: {
        $v = $M->version;     ok $v, $x.'->version = '.$v;
        $v = $M->description; ok $v, $x.'->description = '.$v;
        $v = $M->smtpagent;   ok $v, $x.'->smtpagent = '.$v;

        $M->scan, undef, $M.'->scan = undef';

        PARSE_EACH_MAIL: for my $i ( 1 .. scalar keys %{ $R->{ $x } } ) {
            # Open email in eg/ directory
            my $emailfn = sprintf( "./eg/maildir-as-a-sample/new/%s-%02d.eml", lc($x), $i );
            my $mailbox = Sisimai::Mail->new( $emailfn );

            $n = sprintf( "%02d", $i );
            next unless defined $mailbox;
            ok -f $emailfn, sprintf( "[%s] %s/email = ", $n, $M,$emailfn );

            while( my $r = $mailbox->read ) {
                # Parse each email in eg/ directory
                my $p = Sisimai::Message->new( 'data' => $r );
                my $o = undef;

                isa_ok $p, 'Sisimai::Message';
                isa_ok $p->ds, 'ARRAY';
                isa_ok $p->header, 'HASH';
                isa_ok $p->rfc822, 'HASH';
                ok length $p->from, sprintf( "[%s] %s->from = %s", $n, $M, $p->from );

                for my $e ( @{ $p->ds } ) {

                    for my $ee ( qw|recipient agent| ) {
                        # Length of each variable > 0
                        ok length $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }

                    for my $ee ( qw|
                        date spec reason status command action alias rhost lhost 
                        diagnosis feedbacktype softbounce| ) {
                        # Each key should be exist
                        ok exists $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }

                    # Check the value of the following variables
                    unless( $x =~ m/\AmFILTER\z/ ) {
                        # mFILTER => m-FILTER
                        is   $e->{'agent'}, $x, sprintf( "[%s] %s->agent = %s", $n, $x, $e->{'agent'} );
                    }
                    like $e->{'recipient'}, qr/[0-9A-Za-z@-_.]+/, sprintf( "[%s] %s->recipient = %s", $n, $x, $e->{'recipient'} );

                    for my $ee ( 'rhost', 'lhost' ) {
                        # Check rhost and lhost are valid hostname or not
                        next unless $e->{ $ee };
                        next if $x =~ m/\A(?:qmail|Exim|Exchange|X4)\z/;
                        like $e->{ $ee }, qr/\A(?:localhost|.+[.].+)\z/, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }
                }


                $o = Sisimai::Data->make( 'data' => $p );
                isa_ok $o, 'ARRAY';
                ok scalar @$o, sprintf( "%s/entry = %s", $M, scalar @$o );

                for my $e ( @$o ) {
                    # Check each accessor
                    isa_ok $e, 'Sisimai::Data';
                    ok defined $e->replycode, sprintf( "[%s] %s->replycode = %s", $n, $x, $e->replycode );
                    if( length $e->replycode ) {
                        # Check SMTP Reply Code format
                        like $e->replycode, qr/\A[45]\d\d\z/, sprintf( "[%s] %s->replycode = %s", $n, $x, $e->replycode );
                    }

                    like $e->deliverystatus, $R->{ $x }->{ $n }->{'status'}, sprintf( "[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus );
                    like $e->reason,         $R->{ $x }->{ $n }->{'reason'}, sprintf( "[%s] %s->reason = %s", $n, $x, $e->reason );

                    unlike $e->lhost,     qr/[ ]/, sprintf( "[%s] %s->lhost = %s", $n, $x, $e->lhost );
                    unlike $e->rhost,     qr/[ ]/, sprintf( "[%s] %s->rhost = %s", $n, $x, $e->rhost );
                    unlike $e->alias,     qr/[ ]/, sprintf( "[%s] %s->alias = %s", $n, $x, $e->alias );
                    unlike $e->listid,    qr/[ ]/, sprintf( "[%s] %s->listid = %s", $n, $x, $e->listid );
                    unlike $e->messageid, qr/[ ]/, sprintf( "[%s] %s->messageid = %s", $n, $x, $e->messageid );
                }
                $c++;
            }
        }
        ok $c, $M.'/the number of emails = '.$c;
    }
}


done_testing;
