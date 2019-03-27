use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order::Email;

my $PackageName = 'Sisimai::Order::Email';
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
    my $orderby = $PackageName->by('subject');

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
        like $v, qr/\ASisimai::Bite::(?:Email|JSON)::/, $v;
        use_ok $v;
    }

    for my $v ( keys %$headers ) {
        # Header name table
        like $v, qr/\A[a-z][-a-z]+\z/, $v;
        for my $w ( @{ $headers->{ $v } } ) {
            # Module name test
            like $w, qr/\ASisimai::Bite::(?:Email|JSON)::/, $v.' => '.$w;
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

    isa_ok $PackageName->by('neko'), 'HASH';
    is scalar keys %{ $PackageName->by('neko') }, 0;
}

done_testing;


