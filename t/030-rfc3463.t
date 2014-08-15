use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC3463;

my $PackageName = 'Sisimai::RFC3463';
my $MethodNames = {
    'class' => [ 'status', 'reason', 'getdsn' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $stdreasons = Sisimai::RFC3463->standardcode;
    my $intreasons = Sisimai::RFC3463->internalcode;

    STANDARD_CODE: for my $e ( keys %$stdreasons ) {
        for my $f ( keys %{ $stdreasons->{ $e } } ) {
            my $v = $PackageName->status( $f, substr( $e, 0, 1 ), 's' );
            my $x = $PackageName->reason( $v );

            ok $v, sprintf( "->status(%s) = %s", $f, $v );
            ok $x, sprintf( "->reason(%s) = %s", $v, $x );
            is $PackageName->getdsn( $v ), $v, sprintf( "->getdsn(%s) = %s", $v, $v );
        }
    }

    INTERNAL_CODE: for my $e ( keys %$intreasons ) {
        for my $f ( keys %{ $intreasons->{ $e } } ) {
            my $v = $PackageName->status( $f, substr( $e, 0, 1 ), 'i' );
            my $x = $PackageName->reason( $v );

            ok $v, sprintf( "->status(%s) = %s", $f, $v );
            ok $x, sprintf( "->reason(%s) = %s", $v, $x );
            is $PackageName->getdsn( $v ), $v, sprintf( "->getdsn(%s) = %s", $v, $v );
        }
    }

    is $PackageName->is_softbounce('450 4.7.1 Client host rejected'), 1;
    is $PackageName->is_softbounce('553 5.3.5 system config error'), 0;
}

done_testing;
