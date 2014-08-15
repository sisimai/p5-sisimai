use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Address;

my $PackageName = 'Sisimai::Address';
my $MethodNames = {
    'class' => [ 'new', 'parse', 's3s4', 'expand_verp', 'expand_alias' ],
    'object' => [ 'address', 'host', 'user', 'verp', 'alias' ],
};
my $NewInstance = $PackageName->new( 'maketest@bouncehammer.jp' );

use_ok $PackageName;
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $emailaddrs = [
        'neko@example.jp', 'nyan@example.jp', 'nyanko@example.jp', 'lui@example.jp',
        'aoi@example.jp', 'may@example.jp', 'aoki@example.jp', 'shima@example.jp',
        'chosuke@example.jp', 'akari@example.jp', 'mari@example.jp', '8suke@example.gov',
        '8be@example.gov', 'nekochan@example.jp', 'neko@example.com', 'neko@example.org',
        'neko@example.net', 'neko@example.edu', 'neko@example.cat', 'neko@example.mil',
        'neko@example.gov', 'neko@example.int', 'neko@example.gl', '"neko.."@example.jp',
    ];
    my $emailfroms = [
        q|"Neko" <neko@example.jp>|,
        q|"=?ISO-2022-JP?B?dummy?=" <nyan@example.jp>|,
        q|"N Y A N K O" <nyanko@example.jp>|,
        q|"Shironeko Lui" <lui@example.jp>|,
        q|<aoi@example.jp>|,
        q|<may@example.jp> may@example.jp|,
        q|Odd-Eyes Aoki <aoki@example.jp>|,
        q|Mikeneko Shima <shima@example.jp> SHIMA@EXAMPLE.JP|,
        q|chosuke@neko <chosuke@example.jp>|,
        q|akari@chatora.neko <akari@example.jp>|,
        q|mari <mari@example.jp> mari@host.int|,
        q|8suke@example.gov (Mayuge-Neko)|,
        q|Shibainu Hachibe. (Harima-no-kami) 8be@example.gov|,
        q|nekochan@example.jp|,
        q|<neko@example.com>:|,
        q|"<neko@example.org>"|,
        q|"neko@example.net"|,
        q|'neko@example.edu'|,
        q|`neko@example.cat`|,
        q|(neko@example.mil)|,
        q|[neko@example.gov]|,
        q|{neko@example.int}|,
        q|&lt;neko@example.gl&gt;|,
        q|"neko.."@example.jp|,
    ];
    my $isnotemail = [
        1, 'neko', 'cat%neko.jp', '', undef, {},
    ];

    my $emailindex = 0;
    for my $e ( @$emailfroms ) {
        # ->parse()
        my $v = $PackageName->parse( [ $e ] );
        isa_ok $v, 'ARRAY';
        is scalar @$v, 1;
        ok $v->[0], '->parse = '.$v->[0];
        is $v->[0], $emailaddrs->[ $emailindex ], $v->[0];

        # ->s3s4()
        my $x = $PackageName->s3s4( $e );
        ok $x, '->s3s4 = '.$x;
        is $x, $emailaddrs->[ $emailindex ], $x;

        # ->new()
        my $y = $PackageName->new( $x );
        my $z = [ split( '@', $x ) ];
        isa_ok $y, $PackageName;
        is $y->user, $z->[0], '->user = '.$z->[0];
        is $y->host, $z->[1], '->host = '.$z->[1];
        is $y->address, $x, '->address = '.$x;
        is $y->verp, '', '->verp = ""';
        is $y->alias, '', '->alias = ""';

        $emailindex++;
    }

    VERP: {
        my $e = 'nyaa+neko=example.jp@example.org';
        my $v = $PackageName->new( $e );
        is $PackageName->expand_verp( $e ), $v->address, '->expand_verp = '.$v->address;
        is $v->verp, $e, '->verp = '.$e;
    }

    ALIAS: {
        my $e = 'neko+nyaa@example.jp';
        my $v = $PackageName->new( $e );
        is $PackageName->expand_alias( $e ), $v->address, '->expand_alias = '.$v->address;
        is $v->alias, $e, '->alias = '.$e;
    }

    for my $e ( @$isnotemail ) {
        # ->parse
        my $v = $PackageName->parse( [ $e ] );
        is $v, undef;

        # ->s3s4
        my $x = $PackageName->s3s4( $e );
        is $x, $x;

        # ->new
        my $y = $PackageName->new( $e );
        is $y, undef;
    }
}

done_testing;
