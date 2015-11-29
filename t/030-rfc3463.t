use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC3463;

my $PackageName = 'Sisimai::RFC3463';
my $MethodNames = {
    'class' => [ 'status', 'reason', 'getdsn' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
done_testing;

