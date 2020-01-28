use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $PackageName = 'Sisimai::Order';
my $MethodNames = {
    'class'  => ['make', 'default', 'another'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $pattern = $PackageName->make({ 'subject' => 'delivery failure' });
    my $default = $PackageName->default;
    my $another = $PackageName->another;

    isa_ok $pattern, 'ARRAY';
    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';

    ok scalar @$pattern, scalar(@$pattern).' Modules';
    ok scalar @$default, scalar(@$default).' Modules';
    ok scalar @$another, scalar(@$another).' Modules';

    for my $v ( @$pattern, @$default, @$another ) {
        # Module name test
        like $v, qr/\ASisimai::Lhost::/, $v;
        use_ok $v;
    }
}

done_testing;

