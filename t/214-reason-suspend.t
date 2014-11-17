use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::Suspend;

my $PackageName = 'Sisimai::Reason::Suspend';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'suspend', '->text = suspend';
    ok $PackageName->match('550 5.0.0 Recipient suspend the service');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



