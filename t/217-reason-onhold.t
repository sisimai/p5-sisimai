use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::OnHold;

my $PackageName = 'Sisimai::Reason::OnHold';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'onhold', '->text = onhold';
    is $PackageName->match('5.0.0'), 0;
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

