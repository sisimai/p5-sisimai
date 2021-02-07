use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $Package = 'Sisimai';
my $Samples = {
    'dos' => './set-of-emails/maildir/dos',
    'mac' => './set-of-emails/maildir/mac',
};

MAKETEST: {
    for my $e ( keys %$Samples ) {
        next if $e eq 'mac';
        my $v = $Package->rise($Samples->{ $e });
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'entries = '.scalar @$v;

        for my $r ( @$v ) {
            isa_ok $r, 'Sisimai::Fact';
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
}

done_testing;

