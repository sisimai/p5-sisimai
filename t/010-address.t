use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Address;
use Sisimai::RFC5322;

my $PackageName = 'Sisimai::Address';
my $MethodNames = {
    'class' => [
        'new', 'parse', 's3s4', 'expand_verp', 'expand_alias', 'undisclosed',
    ],
    'object' => ['address', 'host', 'user', 'verp', 'alias', 'TO_JSON'],
};
my $NewInstance = $PackageName->new('maketest@bouncehammer.jp');

use_ok $PackageName;
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $emailaddrs = [
        { 'v' => q|"Neko" <neko@example.jp>|, 'a' => 'neko@example.jp' },
        { 'v' => q|"=?ISO-2022-JP?B?dummy?=" <nyan@example.jp>|, 'a' => 'nyan@example.jp' },
        { 'v' => q|"N Y A N K O" <nyanko@example.jp>|, 'a' => 'nyanko@example.jp' },
        { 'v' => q|"Shironeko Lui" <lui@example.jp>|, 'a' => 'lui@example.jp' },
        { 'v' => q|<aoi@example.jp>|, 'a' => 'aoi@example.jp' },
        { 'v' => q|<may@example.jp> may@example.jp|, 'a' => 'may@example.jp' },
        { 'v' => q|Odd-Eyes Aoki <aoki@example.jp>|, 'a' => 'aoki@example.jp' },
        { 'v' => q|Mikeneko Shima <shima@example.jp> SHIMA@EXAMPLE.JP|, 'a' => 'shima@example.jp' },
        { 'v' => q|chosuke@neko <chosuke@example.jp>|, 'a' => 'chosuke@example.jp' },
        { 'v' => q|akari@chatora.neko <akari@example.jp>|, 'a' => 'akari@example.jp' },
        { 'v' => q|mari <mari@example.jp> mari@host.int|, 'a' => 'mari@example.jp' },
        { 'v' => q|8suke@example.gov (Mayuge-Neko)|, 'a' => '8suke@example.gov' },
        { 'v' => q|Shibainu Hachibe. (Harima-no-kami) 8be@example.gov|, 'a' => '8be@example.gov' },
        { 'v' => q|nekochan@example.jp|, 'a' => 'nekochan@example.jp' },
        { 'v' => q|<neko@example.com>:|, 'a' => 'neko@example.com' },
        { 'v' => q|"<neko@example.org>"|, 'a' => 'neko@example.org' },
        { 'v' => q|"neko@example.net"|, 'a' => 'neko@example.net' },
        { 'v' => q|'neko@example.edu'|, 'a' => 'neko@example.edu' },
        { 'v' => q|`neko@example.cat`|, 'a' => 'neko@example.cat' },
        { 'v' => q|(neko@example.mil)|, 'a' => 'neko@example.mil' },
        { 'v' => q|[neko@example.gov]|, 'a' => 'neko@example.gov' },
        { 'v' => q|{neko@example.int}|, 'a' => 'neko@example.int' },
        { 'v' => q|&lt;neko@example.gl&gt;|, 'a' => 'neko@example.gl' },
        { 'v' => q|"neko.."@example.jp|, 'a' => '"neko.."@example.jp' },
        { 'v' => q|Mail Delivery Subsystem <MAILER-DAEMON>|, 'a' => 'MAILER-DAEMON' },
        { 'v' => q|postmaster|, 'a' => 'postmaster' },
        { 'v' => q|neko.nyaan@example.com|, 'a' => 'neko.nyaan@example.com' },
        { 'v' => q|neko.nyaan+nyan@example.com|, 'a' => 'neko.nyaan+nyan@example.com' },
        { 'v' => q|neko-nyaan@example.com|, 'a' => 'neko-nyaan@example.com' },
        { 'v' => q|neko-nyaan@example.com.|, 'a' => 'neko-nyaan@example.com.' },
        { 'v' => q|n@example.com|, 'a' => 'n@example.com' },
#        { 'v' => q|"neko.nyaan.@.nyaan.jp"@example.com|, 'a' => '"neko.nyaan.@.nyaan.jp"@example.com' },
#        { 'v' => q|"neko.(),:;<>[]\".NYAAN.\"neko@\\ \"neko\".nyaan"@neko.example.com|,
#          'a' => q|"neko.(),:;<>[]\".NYAAN.\"neko@\\ \"neko\".nyaan"@neko.example.com| },
#        { 'v' => q|neko-nyaan@neko-nyaan.example.com|, 'a' => 'neko-nyaan@neko-nyaan.example.com' },
#        { 'v' => q|neko@nyaan|, 'a' => 'neko@nyaan' },
#        { 'v' => q[#!$%&'*+-/=?^_`{}|~@example.org], 'a' => q[#!$%&'*+-/=?^_`{}|~@example.org] },
#        { 'v' => q*"()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org*,
#          'a' => q*"()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org* },
#        { 'v' => q|" "@example.org|, 'a' => '" "@example.org' },
#        { 'v' => q|neko@localhost|, 'a' => 'neko@localhost' },
#        { 'v' => q|neko@[IPv6:2001:DB8::1]|, 'a' => 'neko@[IPv6:2001:DB8::1]' },
    ];

    my $isnotemail = [
        1, 'neko', 'cat%neko.jp', '', undef, {},
    ];

    for my $e ( @$emailaddrs ) {
        # ->parse()
        my $v = $PackageName->parse([$e->{'v'}]);

        isa_ok $v, 'ARRAY';
        is scalar @$v, 1;
        ok $v->[0], '->parse(1) = '.$v->[0];
        is $v->[0], $e->{'a'}, '->parse(2) = '.$e->{'a'};

        # ->s3s4()
        my $x = $PackageName->s3s4($e->{'v'});
        ok $x, '->s3s4(1) = '.$x;
        is $x, $e->{'a'}, '->s3s4(2) = '.$x;

        # ->new()
        my $y = $PackageName->new($x);
        my $z = [split('@', $x)];
        isa_ok $y, $PackageName;
        is $y->user, $z->[0], '->user = '.$z->[0];

        unless( Sisimai::RFC5322->is_mailerdaemon($e->{'v'}) ) {
            is $y->host, $z->[1], '->host = '.$z->[1];
        }

        is $y->address, $x, '->address = '.$x;
        is $y->verp, '', '->verp = ""';
        is $y->alias, '', '->alias = ""';

        if( $e =~ m/[<]MAILER-DAEMON[>]/i ) {
            $v = $PackageName->new($e->{'v'});
            ok $v;
        }
    }

    VERP: {
        my $e = 'nyaa+neko=example.jp@example.org';
        my $v = $PackageName->new($e);
        is $PackageName->expand_verp($e), $v->address, '->expand_verp = '.$v->address;
        is $v->verp, $e, '->verp = '.$e;
    }

    ALIAS: {
        my $e = 'neko+nyaa@example.jp';
        my $v = $PackageName->new($e);
        is $PackageName->expand_alias($e), $v->address, '->expand_alias = '.$v->address;
        is $v->alias, $e, '->alias = '.$e;
    }

    TO_JSON: {
        my $e = 'nyaan@example.org';
        my $v = $PackageName->new($e);
        is $v->TO_JSON, $e, '->TO_JSON = '.$e;
    }

    for my $e ( @$isnotemail ) {
        # ->parse
        my $v = $PackageName->parse([$e]);
        is $v, undef;

        # ->s3s4
        my $x = $PackageName->s3s4($e);
        is $x, $x;

        # ->new
        my $y = $PackageName->new($e);
        is $y, undef;
    }

    UNDISCLOSED: {
        is $PackageName->undisclosed('r'), 'undisclosed-recipient-in-headers@libsisimai.org.invalid';
        is $PackageName->undisclosed('s'), 'undisclosed-sender-in-headers@libsisimai.org.invalid';
        is $PackageName->undisclosed(''), undef;
    }







}

done_testing;
