use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::String;

my $PackageName = 'Sisimai::String';
my $MethodNames = {
    'class' => [ 'token', 'is_8bit', 'sweep' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $s = 'envelope-sender@example.jp';
    my $r = 'envelope-recipient@example.org';
    my $t = '239aa35547613b2fa94f40c7f35f4394e99fdd88';

    ok( Sisimai::String->token( $s, $r, 1 ), '->token' );
    is( Sisimai::String->token( $s, $r, 1 ), $t, '->token = '.$t );
    is( Sisimai::String->token( undef  ), '', '->token = ""' );
    is( Sisimai::String->token( $s ), '', '->token = ""' );
    is( Sisimai::String->token( $s, $r ), '', '->token = ""' );
    ok( Sisimai::String->token( $s, $r, 0 ), '->token' );

    is( Sisimai::String->is_8bit( \$s ), 0, '->is_8bit = 0' );
    is( Sisimai::String->is_8bit( \'日本語' ), 1, '->is_8bit = 1' );

    is( Sisimai::String->sweep( undef ), undef, '->sweep = ""' );
    is( Sisimai::String->sweep( ' neko cat '), 'neko cat', '->sweep = "neko cat"' );
    is( Sisimai::String->sweep( ' nyaa   !!'), 'nyaa !!', '->sweep = "nyaa !!"' );
}

done_testing;
