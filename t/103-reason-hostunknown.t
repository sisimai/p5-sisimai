use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::HostUnknown;

my $PackageName = 'Sisimai::Reason::HostUnknown';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'hostunknown', '->text = hostunknown';
    ok $PackageName->match('550 5.2.1 Host Unknown');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

