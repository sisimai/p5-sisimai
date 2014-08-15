use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::ContentError;

my $PackageName = 'Sisimai::Reason::ContentError';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'contenterror', '->text = contenterror';
    ok $PackageName->match('550 5.6.0 Message Filtered');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



