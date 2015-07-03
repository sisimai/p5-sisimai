use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $PackageName = 'Sisimai';
my $SampleEmail = {
    'dos' => './eg/maildir-as-a-sample/dos',
    'mac' => './eg/maildir-as-a-sample/mac',
};

MAKE_TEST: {

    for my $e ( keys %$SampleEmail ) {

        next if $e eq 'mac';
        my $v = $PackageName->make( $SampleEmail->{ $e } );
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'entries = '.scalar @$v;

        for my $r ( @$v ) {
            isa_ok $r, 'Sisimai::Data';
            isa_ok $r->timestamp, 'Sisimai::Time';
            isa_ok $r->addresser, 'Sisimai::Address';
            isa_ok $r->recipient, 'Sisimai::Address';
            ok $r->addresser->address, '->addresser = '.$r->addresser->address;
            ok $r->recipient->address, '->recipient = '.$r->recipient->address;
            ok length $r->reason, '->reason = '.$r->reason;
            ok defined $r->replycode, '->replycode = '.$r->replycode;

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
            ok length $j, 'length( dump("json") ) = '.length $j;
        }
    }
}

done_testing;

