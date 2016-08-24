use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $PackageName = 'Sisimai';
my $UndefinedES = './set-of-emails/to-be-debugged-because/reason-is-undefined';

MAKE_TEST: {
    my $v = $PackageName->make($UndefinedES);
    isa_ok $v, 'ARRAY';
    ok scalar @$v, 'entries = '.scalar @$v;

    for my $r ( @$v ) {
        isa_ok $r, 'Sisimai::Data';
        isa_ok $r->timestamp, 'Sisimai::Time';
        isa_ok $r->addresser, 'Sisimai::Address';
        isa_ok $r->recipient, 'Sisimai::Address';
        ok $r->addresser->address, '->addresser = '.$r->addresser->address;
        ok $r->recipient->address, '->recipient = '.$r->recipient->address;
        ok $r->deliverystatus, '->deliverystatus = '.$r->deliverystatus;
        is $r->reason, 'undefined', '->reason = undefined';

        my $h = $r->damn;
        isa_ok $h, 'HASH';
        ok scalar keys %$h;
        is $h->{'recipient'}, $r->recipient->address, '->recipient = '.$h->{'recipient'};
        is $h->{'addresser'}, $r->addresser->address, '->addresser = '.$h->{'addresser'};

        for my $p ( keys %$h ) {
            next if ref $r->$p;
            next if $p eq 'subject';
            is $h->{ $p }, $r->$p, '->'.$p.' = '.$h->{ $p };
        }

        my $j = $r->dump('json');
        ok length $j, 'length(dump("json")) = '.length $j;
    }
}

done_testing;

