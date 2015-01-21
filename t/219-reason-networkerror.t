use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::NetworkError;

my $PackageName = 'Sisimai::Reason::NetworkError';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'networkerror', '->text = networkerror';
    ok $PackageName->match('554 5.4.6 Too many hops');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



