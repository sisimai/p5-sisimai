use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC5321;

my $PackageName = 'Sisimai::RFC5321';
my $MethodNames = {
    'class' => [ 'getrc' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
done_testing;

