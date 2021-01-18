use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Lhost;

my $Package = 'Sisimai::Lhost';
my $Methods = {
    'class'  => [ 'description', 'make', 'index', 'path', 'DELIVERYSTATUS', 'INDICATORS' ],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is $Package->description, '', '->description';
    is $Package->make, undef, '->make';

    isa_ok $Package->index, 'ARRAY';
    ok scalar @{ $Package->index };

    isa_ok $Package->path, 'HASH';
    ok scalar keys %{ $Package->path };

    isa_ok $Package->DELIVERYSTATUS, 'HASH';
    ok scalar keys %{ $Package->DELIVERYSTATUS };

    isa_ok $Package->INDICATORS, 'HASH';
    ok scalar keys %{ $Package->INDICATORS };
}
done_testing;
