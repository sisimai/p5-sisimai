use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $PackageName = 'Sisimai::Order';
my $MethodNames = {
    'class'  => ['make', 'by', 'default', 'another'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $pattern = $PackageName->make({ 'subject' => 'delivery failure' });
    my $default = $PackageName->default;
    my $another = $PackageName->another;
    my $orderby = $PackageName->by('subject');

    isa_ok $pattern, 'ARRAY';
    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';
    isa_ok $orderby, 'HASH';

    ok scalar @$pattern, scalar(@$pattern).' Modules';
    ok scalar @$default, scalar(@$default).' Modules';
    ok scalar @$another, scalar(@$another).' Modules';
    ok keys %$orderby, scalar(keys %$orderby).' Patterns';

    for my $v ( @$pattern, @$default, @$another ) {
        # Module name test
        like $v, qr/\ASisimai::Lhost::/, $v;
        use_ok $v;
    }

    for my $v ( keys %$orderby ) {
        # Pattern table for detecting MTA
        ok $v, 'subject =~ '.$v;
        ok scalar @{ $orderby->{ $v } };
        for my $w ( @{ $orderby->{ $v } } ) {
            ok length $w;
            use_ok $w;
        }
    }

    isa_ok $PackageName->by('neko'), 'HASH';
    is scalar keys %{ $PackageName->by('neko') }, 0;
}

done_testing;

