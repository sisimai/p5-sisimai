use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::HasMoved;

my $PackageName = 'Sisimai::Reason::HasMoved';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'hasmoved', '->text = hasmoved';
    ok $PackageName->match('550 5.1.6 address neko@cat.cat has been replaced by neko@example.jp');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

