use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $PackageName = 'Sisimai::Order';
my $MethodNames = {
    'class' => ['by', 'default', 'another', 'headers'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $default = Sisimai::Order->default;
    my $another = Sisimai::Order->another;
    my $headers = Sisimai::Order->headers;
    my $orderby = Sisimai::Order->by('subject');

    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';
    isa_ok $headers, 'HASH';
    isa_ok $orderby, 'HASH';

    ok scalar @$default, scalar(@$default).' Modules';
    ok scalar @$another, scalar(@$another).' Modules';
    ok keys %$headers, scalar(keys %$headers).' Headers';
    ok keys %$orderby, scalar(keys %$orderby).' Patterns';

    for my $v ( @$default, @$another ) {
        # Module name test
        like $v, qr/\ASisimai::(?:MTA|MSP|CED)::/, $v;
        use_ok $v;
    }

    for my $v ( keys %$headers ) {
        # Header name table
        like $v, qr/\A[a-z][-a-z]+\z/, $v;
        for my $w ( keys %{ $headers->{ $v } } ) {
            # Module name test
            like $w, qr/\ASisimai::(?:MTA|MSP|CED)::/, $v.' => '.$w;
            is $headers->{ $v }->{ $w }, 1;
        }
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
}

done_testing;

