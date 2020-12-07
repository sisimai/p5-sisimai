use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Lhost;

my $Package = 'Sisimai::Lhost';
my $Methods = {
    'class' => [
        'description', 'make', 'index', 'path',
        'DELIVERYSTATUS', 'INDICATORS',
    ],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is $Package->description, '', '->description';
    is $Package->make, undef, '->make';

    isa_ok $Package->index, 'ARRAY';
    isa_ok $Package->path, 'HASH';
    isa_ok $Package->DELIVERYSTATUS, 'HASH';
    isa_ok $Package->INDICATORS, 'HASH';
}
done_testing;
