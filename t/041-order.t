use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $PackageName = 'Sisimai::Order';
my $MethodNames = {
    'class' => [ 'default', 'headers' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $default = Sisimai::Order->default;
    my $headers = Sisimai::Order->headers;

    isa_ok $default, 'ARRAY';
    isa_ok $headers, 'HASH';
    ok scalar @$default, scalar( @$default ).' Modules';
    ok keys %$headers, scalar( keys %$headers ).' Headers';

    for my $v ( @$default ) {
        # Module name test
        like $v, qr/\ASisimai::(?:MTA|MSP)::/, $v;
        use_ok $v;
    }

    for my $v ( keys %$headers ) {
        # Header name table
        like $v, qr/\A[a-z][-a-z]+\z/, $v;
        for my $w ( keys %{ $headers->{ $v } } ) {
            # Module name test
            like $w, qr/\ASisimai::(?:MTA|MSP)::/, $v.' => '.$w;
            is $headers->{ $v }->{ $w }, 1;
        }
    }
}

done_testing;

