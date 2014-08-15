use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::Filtered;

my $PackageName = 'Sisimai::Reason::Filtered';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'filtered', '->text = filtered';
    ok $PackageName->match('550 5.1.2 User reject');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



