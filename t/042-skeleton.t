use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Skeleton;

my $PackageName = 'Sisimai::Skeleton';
my $MethodNames = {
    'class' => ['DELIVERYSTATUS', 'INDICATORS'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
    isa_ok $PackageName->INDICATORS, 'HASH';
}
done_testing;
