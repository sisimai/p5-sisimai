use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost::Spectrum';
my $MethodNames = {
    'class' => ['get'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $rs = {
        '01' => { 'status' => qr/\A5[.]1[.]0\z/, 'reason' => qr/toomanyconn/ },
    };
    is $PackageName->get, undef;

    use Sisimai::Mail;
    use Sisimai::Data;
    use Sisimai::Message;

    PARSE_EACH_MAIL: for my $n ( keys %$rs ) {
        my $emailfn = sprintf("./set-of-emails/maildir/bsd/rhost-spectrum-%02d.eml", $n);
        my $mailbox = Sisimai::Mail->new($emailfn);
        my $mtahost = qr/charter[.]net\z/;
        next unless defined $mailbox;

        while( my $r = $mailbox->data->read ) {
            my $p = Sisimai::Message->new('data' => $r);
            isa_ok $p, 'Sisimai::Message';
            isa_ok $p->ds, 'ARRAY';
            isa_ok $p->header, 'HASH';
            isa_ok $p->rfc822, 'HASH';
            ok length $p->from;

            for my $e ( @{ $p->ds } ) {
                is $e->{'spec'}, 'SMTP', '->spec = SMTP';
                ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
                like $e->{'recipient'}, $mtahost, '->recipient includes '.$mtahost;
                like $e->{'status'}, $rs->{ $n }->{'status'}, '->status = '.$e->{'status'};
                is $e->{'command'}, '', '->command = '.$e->{'command'};
                ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
                ok length $e->{'action'}, '->action = '.$e->{'action'};
                ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
                ok exists $e->{'alias'}, '->alias = '.$e->{'alias'};
            }

            my $v = Sisimai::Data->make('data' => $p);
            for my $e ( @$v ) {
                like $e->reason, $rs->{ $n }->{'reason'}, '->reason = '.$e->reason;
            }
        }
    }
}

done_testing;

