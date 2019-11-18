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
    my $another = $PackageName->another;
    my $headers = $PackageName->headers;

    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';
    isa_ok $headers, 'HASH';

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



