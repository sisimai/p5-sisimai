use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost::ExchangeOnline';
my $MethodNames = {
    'class' => ['get'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $rs = {
        '01' => { 'status' => qr/\A5[.]7[.]606\z/, 'reason' => qr/blocked/ },
        '02' => { 'status' => qr/\A5[.]4[.]1\z/,   'reason' => qr/rejected/ },
        '03' => { 'status' => qr/\A5[.]1[.]10\z/,  'reason' => qr/userunknown/ },
    };
    is $PackageName->get, undef;

    use Sisimai::Mail;
    use Sisimai::Data;
    use Sisimai::Message;

    PARSE_EACH_MAIL: for my $n ( keys %$rs ) {
        my $emailfn = sprintf("./set-of-emails/maildir/bsd/rhost-exchangeonline-%02d.eml", $n);
        my $mailbox = Sisimai::Mail->new($emailfn);
        my $mtahost = qr/[.].+[.](?:prod|protection)[.]outlook[.]com/;
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
                ok length $e->{'date'}, '->date = '.$e->{'date'};
                ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
                ok length $e->{'action'}, '->action = '.$e->{'action'};
                ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
                ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
                ok defined $e->{'alias'}, '->alias = '.$e->{'alias'};
                ok defined $e->{'command'}, '->command = '.$e->{'command'};
                like $e->{'rhost'}, $mtahost, '->rhost = '.$mtahost;
                like $e->{'agent'}, qr/\A(?:Postfix|Sendmail|RFC3464)/, '->agent = '.$e->{'agent'};
                like $e->{'status'}, $rs->{ $n }->{'status'}, '->status = '.$e->{'status'};
            }

            my $v = Sisimai::Data->make('data' => $p);
            for my $e ( @$v ) {
                like $e->reason, $rs->{ $n }->{'reason'}, '->reason = '.$e->reason;
            }
        }
    }
}

done_testing;


