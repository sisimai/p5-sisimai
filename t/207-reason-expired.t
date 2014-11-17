use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::Expired;

my $PackageName = 'Sisimai::Reason::Expired';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'expired', '->text = expired';
    ok $PackageName->match('400 4.4.7 Delivery time Expired');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;




