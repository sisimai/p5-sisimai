use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order::JSON;

my $PackageName = 'Sisimai::Order::JSON';
my $MethodNames = {
    'class' => ['by', 'default', 'another', 'headers'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $default = $PackageName->default;

    isa_ok $default, 'ARRAY';
    ok scalar @$default, scalar(@$default).' Modules';

    for my $v ( @$default ) {
        # Module name test
        like $v, qr/\ASisimai::Lhost::/, $v;
        use_ok $v;
    }

    isa_ok $PackageName->by('neko'), 'HASH';
    is scalar keys %{ $PackageName->by('neko') }, 0;
}

done_testing;



