use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC2606;

my $PackageName = 'Sisimai::RFC2606';
my $MethodNames = {
    'class' => [ 'is_reserved' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $arerfc2606 = [ 'example.jp', 'example.com', 'example.org', 'example.net' ];
    my $notrfc2606 = [ 'bouncehammer.jp', 'cubicroot.jp', 'gmail.com', 'me.com' ];

    for my $e ( @$arerfc2606 ) {
        is $PackageName->is_reserved( $e ), 1, '->is_reserved('.$e.') = 1';
    }
    for my $e ( @$notrfc2606 ) {
        is $PackageName->is_reserved( $e ), 0, '->is_reserved('.$e.') = 0';
    }
}

done_testing;

