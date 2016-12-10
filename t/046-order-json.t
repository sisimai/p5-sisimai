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
    my $orderby = $PackageName->by('keyname');

    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';
    isa_ok $headers, 'HASH';
    isa_ok $orderby, 'HASH';

    ok scalar @$default, scalar(@$default).' Modules';
    ok keys %$orderby, scalar(keys %$orderby).' Patterns';

    for my $v ( @$default ) {
        # Module name test
        like $v, qr/\ASisimai::CED::/, $v;
        use_ok $v;
    }

    for my $v ( keys %$orderby ) {
        # Pattern table for detecting CED
        ok $v, 'subject =~ '.$v;
        ok scalar @{ $orderby->{ $v } };
        for my $w ( @{ $orderby->{ $v } } ) {
            ok length $w;
            use_ok $w;
        }
    }
}

done_testing;



