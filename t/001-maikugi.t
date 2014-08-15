use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use_ok 'Sisimai';

MAKE_TEST: {

    ok $Sisimai::VERSION;
    is( Sisimai->sysname, 'bouncehammer' );
    is( Sisimai->libname, 'Sisimai' );
}

done_testing;
