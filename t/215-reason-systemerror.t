use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::SystemError;

my $PackageName = 'Sisimai::Reason::SystemError';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'systemerror', '->text = systemerror';
    ok $PackageName->match('500 5.3.5 System config error');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



