use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::TooManyConn;

my $PackageName = 'Sisimai::Reason::TooManyConn';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'toomanyconn', '->text = toomanyconn';
    ok $PackageName->match('421	Too many connections');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

