use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC5965;

my $Package = 'Sisimai::RFC5965';
my $Methods = {
    'class'  => ['FIELDINDEX'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $v = $Package->FIELDINDEX;
    isa_ok $v, 'ARRAY', '->FIELDINDEX() returns ARRAY';
    ok scalar @$v,      '->FIELDINDEX() returns ARRAY';
}

done_testing;

