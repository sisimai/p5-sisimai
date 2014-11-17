use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::MesgTooBig;

my $PackageName = 'Sisimai::Reason::MesgTooBig';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'mesgtoobig', '->text = mesgtoobig';
    ok $PackageName->match('400 4.2.2 Message too big');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



