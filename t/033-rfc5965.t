use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC5965;

my $Package = 'Sisimai::RFC5965';
my $Methods = {
    'class'  => [],
    'object' => [],
};

use_ok $Package;

MAKETEST: {
    my $v = $Package->FIELDINDEX;
    isa_ok $v, 'ARRAY', '->FIELDINDEX returns ARRAY';
    ok scalar @$v,      '->FIELDINDEX returns ARRAY';
}

done_testing;

