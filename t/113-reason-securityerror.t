use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::SecurityError;

my $PackageName = 'Sisimai::Reason::SecurityError';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'securityerror', '->text = securityerror';
    ok $PackageName->match('570 5.7.7 Email not accepted for policy reasons');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



