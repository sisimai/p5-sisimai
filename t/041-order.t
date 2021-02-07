use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $Package = 'Sisimai::Order';
my $Methods = {
    'class'  => ['make', 'default', 'another'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $pattern = $Package->make('delivery failure');
    my $default = $Package->default;
    my $another = $Package->another;

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

