use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::ExceedLimit;

my $PackageName = 'Sisimai::Reason::ExceedLimit';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'exceedlimit', '->text = exceedlimit';
    is $PackageName->match, undef;
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



