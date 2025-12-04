use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Lhost;

my $Package = 'Sisimai::Lhost';
my $Methods = {
    'class'  => [ 'description', 'inquire', 'index', 'path', 'DELIVERYSTATUS', 'INDICATORS' ],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is $Package->description, '', '->description';
    is $Package->inquire,  undef, '->inquire';

    isa_ok $Package->index, 'ARRAY';
    ok scalar @{ $Package->index };

    isa_ok $Package->path, 'HASH';
    ok scalar keys %{ $Package->path };

    isa_ok $Package->DELIVERYSTATUS, 'HASH';
    is scalar(keys %{ $Package->DELIVERYSTATUS }), 15;

    isa_ok $Package->INDICATORS, 'HASH';
    is scalar(keys %{ $Package->INDICATORS }), 2;
}
done_testing;
