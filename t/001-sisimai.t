use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $PackageName = 'Sisimai';
my $MethodNames = {
    'class' => [ 'sysname', 'libname', 'version', 'make' ],
    'object' => [],
};
my $SampleEmail = {
    'mailbox' => './eg/mbox-as-a-sample',
    'maildir' => './eg/maildir-as-a-sample/new',
};
my $IsNotBounce = {
    'maildir' => './eg/maildir-as-a-sample/tmp',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {

    is $PackageName->sysname, 'bouncehammer', '->sysname = bouncehammer';
    is $PackageName->libname, $PackageName, '->libname = '.$PackageName;
    is $PackageName->version, $Sisimai::VERSION, '->version = '.$Sisimai::VERSION;
    is $PackageName->make(undef), undef;

    for my $e ( 'mailbox', 'maildir' ) {

        my $v = $PackageName->make( $SampleEmail->{ $e } );
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'entries = '.scalar @$v;

        for my $r ( @$v ) {
            isa_ok $r, 'Sisimai::Data';
            isa_ok $r->date, 'Time::Piece';
            isa_ok $r->addresser, 'Sisimai::Address';
            isa_ok $r->recipient, 'Sisimai::Address';
            ok $r->addresser->address, '->addresser = '.$r->addresser->address;
            ok $r->recipient->address, '->recipient = '.$r->recipient->address;
            ok length $r->reason, '->reason = '.$r->reason;

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

    for my $e ( 'maildir' ) {
        my $v = $PackageName->make( $IsNotBounce->{ $e } );
        is $v, undef;
    }

}

done_testing;
