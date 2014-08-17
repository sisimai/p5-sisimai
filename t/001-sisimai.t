use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $PackageName = 'Sisimai';
my $MethodNames = {
    'class' => [ 'sysname', 'libname', 'version' ],
    'object' => [],
};
my $SampleEmail = {
    'mailbox' => './eg/mbox-as-a-sample',
    'maildir' => './eg/maildir-as-a-sample/new',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {

    is $PackageName->sysname, 'bouncehammer', '->sysname = bouncehammer';
    is $PackageName->libname, $PackageName, '->libname = '.$PackageName;
    is $PackageName->version, $Sisimai::VERSION, '->version = '.$Sisimai::VERsiON;
    is $PackageName->parse(undef), undef;

    my $v = $PackageName->parse( $SampleEmail->{'mailbox'} );
    isa_ok $v, 'ARRAY';
    ok scalar @$v, 'entries = '.scalar @$v;
    
    for my $r ( @$v ) {
        isa_ok $r, 'Sisimai::Data';
        ok $r->addresser->address, '->addresser = '.$r->addresser->address;
        ok $r->recipient->address, '->recipient = '.$r->recipient->address;
        ok length $r->reason, '->recipient = '.$r->reason;
    }
}

done_testing;
