use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost::FrancePTT';
my $MethodNames = {
    'class' => ['get'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $rs = {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/ },
        '02' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/userunknown/ },
        '03' => { 'status' => qr/\A5[.]2[.]0\z/, 'reason' => qr/spamdetected/ },
        '04' => { 'status' => qr/\A5[.]2[.]0\z/, 'reason' => qr/spamdetected/ },
        '05' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/suspend/ },
        '06' => { 'status' => qr/\A4[.]0[.]0\z/, 'reason' => qr/blocked/ },
        '07' => { 'status' => qr/\A4[.]0[.]0\z/, 'reason' => qr/blocked/ },
        '08' => { 'status' => qr/\A4[.]2[.]0\z/, 'reason' => qr/systemerror/ },
        '10' => { 'status' => qr/\A4[.]5[.]0\z/, 'reason' => qr/undefined/ },
        '11' => { 'status' => qr/\A4[.]2[.]1\z/, 'reason' => qr/undefined/ },
    };
    is $PackageName->get, undef;

    use Sisimai::Mail;
    use Sisimai::Data;
    use Sisimai::Message;

    PARSE_EACH_MAIL: for my $n ( keys %$rs ) {
        my $emailfn = sprintf("./set-of-emails/maildir/bsd/rhost-franceptt-%02d.eml", $n);
        my $mailbox = Sisimai::Mail->new($emailfn);
        my $mtahost = qr/(?:smtp-in[.]orange[.]fr|smtpz4[.]laposte[.]net|smtp[.]wanadoo[.]fr)/;
        next unless defined $mailbox;

        while( my $r = $mailbox->data->read ) {

            my $p = Sisimai::Message->new('data' => $r);
            isa_ok $p, 'Sisimai::Message';
            isa_ok $p->ds, 'ARRAY';
            isa_ok $p->header, 'HASH';
            isa_ok $p->rfc822, 'HASH';
            ok length $p->from;

            for my $e ( @{ $p->ds } ) {
                ok defined $e->{'spec'}, '->spec = '.$e->{'spec'};
                ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
                like $e->{'status'}, $rs->{ $n }->{'status'}, '->status = '.$e->{'status'};
                like $e->{'command'}, qr/[A-Z]{4}/, '->command = '.$e->{'command'};
                ok defined $e->{'date'}, '->date = '.$e->{'date'};
                ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
                ok defined $e->{'action'}, '->action = '.$e->{'action'};
                like $e->{'rhost'}, $mtahost, '->rhost = '.$e->{'rhost'};
                ok defined $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
                ok exists $e->{'alias'}, '->alias = '.$e->{'alias'};
                like $e->{'agent'}, qr/\A(?:EinsUndEins|Exim|Postfix|Sendmail)/, '->agent = '.$e->{'agent'};
            }

            my $v = Sisimai::Data->make('data' => $p);
            for my $e ( @$v ) {
                like $e->reason, $rs->{ $n }->{'reason'}, '->reason = '.$e->reason;
            }
        }
    }
}

done_testing;




