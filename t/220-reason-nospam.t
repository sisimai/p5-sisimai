use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::NoSpam;

my $PackageName = 'Sisimai::Reason::NoSpam';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'nospam', '->text = nospam';
    ok $PackageName->match('570 5.7.7 Spam Detected');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

