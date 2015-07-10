use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC3464;

my $PackageName = 'Sisimai::RFC3464';
my $MethodNames = {
    'class' => [ 
        'version', 'description', 'smtpagent', 'scan',
    ],
    'object' => [],
};
my $ReturnValue = {
    '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/dovecot/ },
    '02' => { 'status' => qr/\A[45][.]0[.]\d+\z/, 'reason' => qr/(?:undefined|filtered|expired)/, 'agent' => qr/RFC3464/ },
    '03' => { 'status' => qr/\A[45][.]0[.]\d+\z/, 'reason' => qr/(?:undefined|expired)/, 'agent' => qr/RFC3464/ },
    '04' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
    '05' => { 'status' => qr/\A5[.]2[.]1\z/, 'reason' => qr/filtered/, 'agent' => qr/RFC3464/ },
    '06' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/userunknown/, 'agent' => qr/mail.local/ },
    '07' => { 'status' => qr/\A4[.]4[.]0\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
    '08' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/spamdetected/, 'agent' => qr/RFC3464/ },
    '09' => { 'status' => qr/\A4[.]3[.]0\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
    '10' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/, 'agent' => qr/RFC3464/ },
    '11' => { 'status' => qr/\A5[.]\d[.]\d+\z/, 'reason' => qr/spamdetected/, 'agent' => qr/RFC3464/ },
    '12' => { 'status' => qr/\A4[.]3[.]0\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
    '13' => { 'status' => qr/\A4[.]0[.]0\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
    '14' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
    '15' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mesgtoobig/, 'agent' => qr/RFC3464/ },
    '16' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/, 'agent' => qr/RFC3464/ },
    '17' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
    '18' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/, 'agent' => qr/RFC3464/ },
    '19' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/, 'agent' => qr/RFC3464/ },
    '20' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
    '21' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/, 'agent' => qr/RFC3464/ },
    '22' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/, 'agent' => qr/RFC3464/ },
    '23' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
    '24' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/, 'agent' => qr/RFC3464/ },
    '25' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/undefined/, 'agent' => qr/RFC3464/ },
};
my $RxAgentName = qr/\A(?:RFC3464|dovecot|mail[.]local|procmail|maildrop|vpopmail|vmailmgr)/;

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v = undef;
    my $c = 0;

    $v = $PackageName->version;
    ok $v, '->version = '.$v;
    $v = $PackageName->description;
    ok $v, '->description = '.$v;

    $v = $PackageName->smtpagent;
    ok $v, '->smtpagent = '.$v;

    is $PackageName->scan, undef, '->scan';

    use Sisimai::Data;
    use Sisimai::Mail;
    use Sisimai::Message;

    PARSE_EACH_MAIL: for my $n ( 1..20 ) {

        my $emailfn = sprintf( "./eg/maildir-as-a-sample/new/rfc3464-%02d.eml", $n );
        my $mailbox = Sisimai::Mail->new( $emailfn );
        my $emindex = sprintf( "%02d", $n );
        next unless defined $mailbox;
        ok -f $emailfn, 'email = '.$emailfn;

        while( my $r = $mailbox->read ) {

            my $p = Sisimai::Message->new( 'data' => $r );
            my $o = undef;
            isa_ok $p, 'Sisimai::Message';
            isa_ok $p->ds, 'ARRAY';
            isa_ok $p->header, 'HASH';
            isa_ok $p->rfc822, 'HASH';
            ok length $p->from;

            for my $e ( @{ $p->ds } ) {
                ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
                like $e->{'agent'}, $RxAgentName, '->agent = '.$e->{'agent'};

                ok exists $e->{'date'}, '->date = '.$e->{'date'};
                ok exists $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
                ok exists $e->{'spec'}, '->spec = '.$e->{'spec'};
                ok exists $e->{'reason'}, '->reason = '.$e->{'reason'};
                ok exists $e->{'status'}, '->status = '.$e->{'status'};
                ok exists $e->{'command'}, '->command = '.$e->{'command'};
                ok exists $e->{'action'}, '->action = '.$e->{'action'};
                ok exists $e->{'alias'}, '->alias = '.$e->{'alias'};
                ok exists $e->{'feedbacktype'}, '->feedbacktype = ""';
                ok exists $e->{'softbounce'}, '->softbounce = '.$e->{'softbounce'};

                ok exists $e->{'rhost'}, '->rhost = '.$e->{'rhost'};
                ok exists $e->{'lhost'}, '->lhost = '.$e->{'lhost'};

                for my $q ( 'rhost', 'lhost' ) {
                    next unless $e->{ $q };
                    like $e->{ $q }, qr/\A.+[.].+\z/, '->'.$q.' = '.$e->{ $q };
                }
            }

            $o = Sisimai::Data->make( 'data' => $p );
            ok scalar @$o, 'entry = '.scalar @$o;
            for my $e ( @$o ) {
                isa_ok $e, 'Sisimai::Data';
                like $e->deliverystatus, $ReturnValue->{ $emindex }->{'status'}, '->status = '.$e->deliverystatus;
                like $e->reason, $ReturnValue->{ $emindex }->{'reason'}, '->reason = '.$e->reason;
                like $e->smtpagent, $ReturnValue->{ $emindex }->{'agent'}, '->agent = '.$e->smtpagent;
                ok defined $e->replycode, '->replycode = '.$e->replycode;
            }
            $c++;
        }
    }
    ok $c, 'the number of emails = '.$c;
}
done_testing;

