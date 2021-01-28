use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $Package = 'Sisimai';
my $Samples = './set-of-emails/to-be-debugged-because/reason-is-undefined';

MAKETEST: {
    plan 'skip_all', sprintf("%s does not exist", $Samples) unless -d $Samples;
    my $v = $Package->make($Samples);
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

            if( $p eq 'catch' ) {
                is $h->{ $p }, '', '->'.$p.' = ""';
            } else {
                is $h->{ $p }, $r->$p, '->'.$p.' = '.$h->{ $p };
            }
        }

        my $j = $r->dump('json');
        ok length $j, 'length(dump("json")) = '.length $j;
    }
}

done_testing;

