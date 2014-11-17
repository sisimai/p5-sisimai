use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::Rejected;

my $PackageName = 'Sisimai::Reason::Rejected';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'rejected', '->text = rejected';
    ok $PackageName->match('550 5.1.0 Address rejected');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



