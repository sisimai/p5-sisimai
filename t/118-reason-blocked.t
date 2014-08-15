use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::Blocked;

my $PackageName = 'Sisimai::Reason::Blocked';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'blocked', '->text = blocked';
    ok $PackageName->match('550 Access from ip address 192.0.2.1 blocked.');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



