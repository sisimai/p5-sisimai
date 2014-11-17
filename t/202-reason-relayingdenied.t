use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::RelayingDenied;

my $PackageName = 'Sisimai::Reason::RelayingDenied';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'norelaying', '->text = norelaying';
    ok $PackageName->match('550 5.0.0 Relaying Denied');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;
