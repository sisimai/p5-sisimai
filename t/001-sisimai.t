use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;

my $PackageName = 'Sisimai';
my $MethodNames = {
    'class' => [ 'sysname', 'libname', 'parse' ],
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
    is $PackageName->parse(undef), undef;

    my $v = $PackageName->parse( $SampleEmail->{'mailbox'} );
    #isa_ok $v, 'ARRAY';
}

done_testing;
