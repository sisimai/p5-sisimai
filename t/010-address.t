use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Address;
use Sisimai::RFC5322;

my $Package = 'Sisimai::Address';
my $Methods = {
    'class'  => [
        'new', 'find', 's3s4', 'expand_verp', 'expand_alias', 'undisclosed',
        'is_emailaddress', 'is_mailerdaemon'
    ],
    'object' => ['address', 'host', 'user', 'verp', 'alias', 'name', 'comment', 'TO_JSON'],
};
my $NewInstance = $Package->new({ 'address' => 'maketest@bouncehammer.jp' });

use_ok $Package;
isa_ok $NewInstance, $Package;
can_ok $NewInstance, @{ $Methods->{'object'} };
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $emailaddrs = [
        { 'v' => '"Neko" <neko@example.jp>', 'a' => 'neko@example.jp', 'n' => 'Neko', 'c' => '' },
        { 'v' => '"=?ISO-2022-JP?B?dummy?=" <nyan@example.jp>',
          'a' => 'nyan@example.jp',
          'n' => '=?ISO-2022-JP?B?dummy?=',
          'c' => '', },
        { 'v' => '"N Y A N K O" <nyanko@example.jp>',
          'a' => 'nyanko@example.jp',
          'n' => 'N Y A N K O',
          'c' => '', },
        { 'v' => '"Shironeko Lui" <lui@example.jp>',
          'a' => 'lui@example.jp',
          'n' => 'Shironeko Lui',
          'c' => '', },
        { 'v' => '<aoi@example.jp>', 'a' => 'aoi@example.jp', 'n' => '', 'c' => '' },
        { 'v' => '<may@example.jp> may@example.jp', 'a' => 'may@example.jp', 'n' => 'may@example.jp', 'c' => '' },
        { 'v' => 'Odd-Eyes Aoki <aoki@example.jp>',
          'a' => 'aoki@example.jp',
          'n' => 'Odd-Eyes Aoki',
          'c' => '', },
        { 'v' => 'Mikeneko Shima <shima@example.jp> SHIMA@EXAMPLE.JP',
          'a' => 'shima@example.jp',
          'n' => 'Mikeneko Shima SHIMA@EXAMPLE.JP',
          'c' => '', },
        { 'v' => 'chosuke@neko <chosuke@example.jp>',
          'a' => 'chosuke@example.jp',
          'n' => 'chosuke@neko',
          'c' => '', },
        { 'v' => 'akari@chatora.neko <akari@example.jp>',
          'a' => 'akari@example.jp',
          'n' => 'akari@chatora.neko',
          'c' => '', },
        { 'v' => 'mari <mari@example.jp> mari@host.int',
          'a' => 'mari@example.jp',
          'n' => 'mari mari@host.int',
          'c' => '', },
        { 'v' => '8suke@example.gov (Mayuge-Neko)',
          'a' => '8suke@example.gov',
          'n' => '8suke@example.gov',
          'c' => '(Mayuge-Neko)', },
        { 'v' => 'Shibainu Hachibe. (Harima-no-kami) 8be@example.gov',
          'a' => '8be@example.gov',
          'n' => 'Shibainu Hachibe. 8be@example.gov',
          'c' => '(Harima-no-kami)', },
        { 'v' => 'neko(nyaan)chan@example.jp',
          'a' => 'nekochan@example.jp',
          'n' => 'nekochan@example.jp',
          'c' => '(nyaan)' },
        { 'v' => '(nyaan)neko@example.jp',
          'a' => 'neko@example.jp',
          'n' => 'neko@example.jp',
          'c' => '(nyaan)' },
        { 'v' => 'neko(nyaan)@example.jp',
          'a' => 'neko@example.jp',
          'n' => 'neko@example.jp',
          'c' => '(nyaan)' },
        { 'v' => 'nora(nyaan)neko@example.jp(cat)',
          'a' => 'noraneko@example.jp',
          'n' => 'noraneko@example.jp',
          'c' => '(nyaan) (cat)' },
        { 'v' => '<neko@example.com>:', 'a' => 'neko@example.com', 'n' => ':', 'c' => '' },
        { 'v' => '"<neko@example.org>"', 'a' => 'neko@example.org', 'n' => '', 'c' => '' },
        { 'v' => '"neko@example.net"',
          'a' => 'neko@example.net',
          'n' => 'neko@example.net',
          'c' => '' },
        { 'v' => q|'neko@example.edu'|,
          'a' => 'neko@example.edu',
          'n' => q|'neko@example.edu'|,
          'c' => '' },
        { 'v' => '`neko@example.cat`',
          'a' => 'neko@example.cat',
          'n' => '`neko@example.cat`',
          'c' => '' },
        { 'v' => '[neko@example.gov]',
          'a' => 'neko@example.gov',
          'n' => '[neko@example.gov]',
          'c' => '' },
        { 'v' => '{neko@example.int}',
          'a' => 'neko@example.int',
          'n' => '{neko@example.int}',
          'c' => '' },
        { 'v' => '"neko.."@example.jp',
          'a' => '"neko.."@example.jp',
          'n' => '"neko.."@example.jp',
          'c' => '' },
        { 'v' => 'Mail Delivery Subsystem <MAILER-DAEMON>',
          'a' => 'MAILER-DAEMON',
          'n' => 'Mail Delivery Subsystem',
          'c' => '', },
        { 'v' => 'postmaster', 'a' => 'postmaster', 'n' => 'postmaster', 'c' => '' },
        { 'v' => 'neko.nyaan@example.com',
          'a' => 'neko.nyaan@example.com',
          'n' => 'neko.nyaan@example.com',
          'c' => '' },
        { 'v' => 'neko.nyaan+nyan@example.com',
          'a' => 'neko.nyaan+nyan@example.com',
          'n' => 'neko.nyaan+nyan@example.com',
          'c' => '', },
        { 'v' => 'neko-nyaan@example.com',
          'a' => 'neko-nyaan@example.com',
          'n' => 'neko-nyaan@example.com',
          'c' => '' },
        { 'v' => 'neko-nyaan@example.org.',
          'a' => 'neko-nyaan@example.org',
          'n' => 'neko-nyaan@example.org.',
          'c' => '' },
        { 'v' => 'n@example.com',
          'a' => 'n@example.com',
          'n' => 'n@example.com',
          'c' => '' },
        { 'v' => '"neko.nyaan.@.nyaan.jp"@example.com',
          'a' => '"neko.nyaan.@.nyaan.jp"@example.com',
          'n' => '"neko.nyaan.@.nyaan.jp"@example.com',
          'c' => '' },
        { 'v' => '"neko nyaan"@example.org',
          'a' => '"neko nyaan"@example.org',
          'n' => '"neko nyaan"@example.org',
          'c' => '' },
#       { 'v' => q|"neko.(),:;<>[]\".NYAAN.\"neko@\\ \"neko\".nyaan"@neko.example.com|,
#         'a' => q|"neko.(),:;<>[]\".NYAAN.\"neko@\\ \"neko\".nyaan"@neko.example.com|,
#         'n' => q|"neko.(),:;<>[]\".NYAAN.\"neko@\\ \"neko\".nyaan"@neko.example.com|,
#         'c' => '' },
        { 'v' => q|neko-nyaan@neko-nyaan.example.com|,
          'a' => 'neko-nyaan@neko-nyaan.example.com',
          'n' => 'neko-nyaan@neko-nyaan.example.com',
          'c' => '' },
        { 'v' => 'neko@nyaan', 'a' => 'neko@nyaan', 'n' => 'neko@nyaan', 'c' => '' },
        { 'v' => q[#!$%&'*+-/=?^_`{}|~@example.org],
          'a' => q[#!$%&'*+-/=?^_`{}|~@example.org],
          'n' => q[#!$%&'*+-/=?^_`{}|~@example.org],
          'c' => '' },
#       { 'v' => q*"()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org*,
#         'a' => q*"()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org*,
#         'n' => q*"()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org*,
#         'c' => '' },
        { 'v' => q|" "@example.org|,
          'a' => '" "@example.org',
          'n' => '" "@example.org',
          'c' => '' },
        { 'v' => q|neko@localhost|,
          'a' => 'neko@localhost',
          'n' => 'neko@localhost',
          'c' => '' },
        { 'v' => 'neko@[IPv6:2001:DB8::1]',
          'a' => 'neko@[IPv6:2001:DB8::1]',
          'n' => 'neko@[IPv6:2001:DB8::1]',
          'c' => '' },
    ];
    my $isnotemail = [
        1, 'neko', 'cat%neko.jp', '', undef, {},
    ];
    my $manyemails = [
        '"Neko, Nyaan" <(nora)neko@example.jp>, Nora Nyaans <neko(nora)@example.jp>',
        'Neko (Nora, Nyaan) <neko@example.jp>, (Neko) "Nora, Mike" <neko@example.jp>',
    ];
    my $postmaster = [
        'mailer-daemon@example.jp', 
        'MAILER-DAEMON@example.cat',
        'Mailer-Daemon <postmaster@example.org>',
        'MAILER-DAEMON',
        'postmaster',
        'postmaster@example.org',
    ];
    my $emailindex = 1;

    my $a = undef;
    my $n = undef;
    my $v = undef;
    my $p = 'Sisimai::Address';

    for my $e ( @$emailaddrs ) {
        $n = sprintf("[%04d/%04d]", $emailindex, scalar @$emailaddrs);
        $a = undef;

        ok length  $e->{'v'}, sprintf("%s Email(v) = %s", $n, $e->{'v'});
        ok length  $e->{'a'}, sprintf("%s Address(a) = %s", $n, $e->{'a'});
        ok defined $e->{'n'}, sprintf("%s Display name(n) = %s", $n, $e->{'n'});
        ok defined $e->{'c'}, sprintf("%s Comment(c) = %s", $n, $e->{'c'});

        FIND: {
            # ->find()
            $v = $p->find($e->{'v'});

            is ref $v, 'ARRAY', sprintf("%s %s->find(v)", $n, $p);
            is scalar @$v, 1, sprintf("%s %s->find(v) returns 1 email address", $n, $p);

            ok $v->[0]->{'address'}, sprintf("%s %s->find(v)->address = %s", $n, $p, $v->[0]->{'address'});
            is $v->[0]->{'address'}, $e->{'a'}, sprintf("%s %s->find(v)->address = %s", $n, $p, $e->{'a'});

            for my $f ('comment', 'name') {
                ok defined $v->[0]->{ $f }, sprintf("%s %s->find(v)->%s = %s", $n, $p, $f, $v->[0]->{ $f });
                is $v->[0]->{ $f }, $e->{ substr($f, 0, 1) }, sprintf("%s %s->find(v)->%s = %s", $n, $p, $f, $v->[0]->{ $f });
            }

            # find(v, 1)
            $v = $p->find($e->{'v'}, 1);

            is ref $v, 'ARRAY', sprintf("%s %s->find(v,1)", $n, $p);
            is scalar @$v, 1, sprintf("%s %s->find(v,1) returns 1 email address", $n, $p);

            ok $v->[0]->{'address'}, sprintf("%s %s->find(v,1)->address = %s", $n, $p, $v->[0]->{'address'});
            is $v->[0]->{'address'}, $e->{'a'}, sprintf("%s %s->find(v,1)->address = %s", $n, $p, $e->{'a'});
            is keys %{ $v->[0] }, 1, sprintf("%s %s->find(v,1) has 1 key", $n, $p);
        }

        NEW: {
            # ->new()
            $v = $p->new(shift @{ $p->find($e->{'v'}) });
            is $v->new(''), undef;
            is $v->new([]), undef;
            is $v->new({'address' => ''}), undef;

            if( $e->{'a'} =~ /\A(.+)[@]([^@]+)\z/ ){ $a->[0] = $1; $a->[1] = $2; }
            if( $Package->is_mailerdaemon($e->{'v'}) ){ $a->[0] = $e->{'a'}; $a->[1] = ''; }

            is ref $v, $p,             sprintf("%s %s->new(v)", $n, $p);
            is $v->address, $e->{'a'}, sprintf("%s %s->new(v)->address= %s", $n, $p, $e->{'a'});
            is $v->user,    $a->[0],   sprintf("%s %s->new(v)->user = %s", $n, $p, $a->[0]);
            is $v->host,    $a->[1],   sprintf("%s %s->new(v)->host = %s", $n, $p, $a->[1]);
            is $v->verp,    '',        sprintf("%s %s->new(v)->verp = ''", $n, $p, '');
            is $v->alias,   '',        sprintf("%s %s->new(v)->alias = ''", $n, $p, '');
            is $v->name,    $e->{'n'}, sprintf("%s %s->new(v)->name = ''", $n, $p, $e->{'n'});
            is $v->comment, $e->{'c'}, sprintf("%s %s->new(v)->comment = ''", $n, $p, $e->{'c'});

            # name, and comment are writable accessor
            $v->name('nyaan');    is $v->name,    'nyaan', sprintf("%s %s->new(v)->name = nyaan", $n, $p);
            $v->comment('nyaan'); is $v->comment, 'nyaan', sprintf("%s %s->new(v)->comment = nyaan", $n, $p);
        }

        S3S4: {
            # ->s3s4()
            $v = $p->s3s4($e->{'v'});

            ok length $v, sprintf("%s %s->s3s4 = %s", $n, $p, $v);
            is $v, $e->{'a'}, sprintf("%s %s->s3s4 = %s", $n, $p, $e->{'a'});
        }

        IS_EMAILADDRESS: {
            if( $e->{'a'} =~ /[@]/ ) {
                # is_emailaddress
                ok $p->is_emailaddress($e->{'a'}), sprintf("%s->is_emailaddress(%s)", $p, $e->{'a'});

            } else {
                ok $p->is_mailerdaemon($e->{'a'}), sprintf("%s->is_mailerdaemon(%s)", $p, $e->{'a'});
            }
        }

        $emailindex++;
    }

    FIND_MANY: {
        for my $e ( @$manyemails ) {
            my $v = Sisimai::Address->find($e);

            is ref $v, 'ARRAY', sprintf("%s %s->find(v)", $n, $p);
            is scalar @$v, 2, sprintf("%s %s->find(v) = 2", $n, $p);

            for my $f ( @$v ) {
                $a = Sisimai::Address->new($f);
                is ref $f, 'HASH',  sprintf("%s %s->find(v)->[]", $n, $p);
                is ref $a, 'Sisimai::Address', sprintf("%s %s->new(f)", $n, $p);
                ok $a->address, sprintf("%s %s->new(f)->address = %s", $n, $p, $a->address);
                ok $a->comment, sprintf("%s %s->new(f)->comment = %s", $n, $p, $a->comment);
                ok $a->name,    sprintf("%s %s->new(f)->name = %s",    $n, $p, $a->name);
            }
        }
    }

    VERP: {
        $a = 'nyaa+neko=example.jp@example.org';
        $v = $p->new({ 'address' => $a });
        is $p->expand_verp($a), 'neko@example.jp', sprintf("%s->expand_verp(%s) = %s", $p, $a, $v);
        is $p->expand_verp(undef), undef;
        is $v->verp, $a, sprintf("%s->new(v)->verp = %s", $p, $a);

    }

    ALIAS: {
        $a = 'neko+nyaa@example.jp';
        $v = $p->new({ 'address' => $a });

        is $p->expand_alias($a), 'neko@example.jp', sprintf("%s->expand_alias(%s) = %s", $p, $a, $v);
        is $p->expand_alias(undef), undef;
        is $v->alias, $a, sprintf("%s->new(v)->alias = %s", $p, $a);
    }

    TO_JSON: {
        $a = 'nyaan@example.org';
        $v = $p->new({ 'address' => $a });
        is $v->TO_JSON, $v->address, sprintf("%s->new(v)->TO_JSON = %s", $p, $a);
    }

    IS_MAILERDAEMON: {
        for my $e ( @$postmaster ) {
            ok $p->is_mailerdaemon($e), sprintf("%s->is_mailerdaemon = %s", $p, $e);
        }
        is $p->is_mailerdaemon(undef), 0;
    }

    IS_NOT_EMAIL: {
        for my $e ( @$isnotemail ) {
            $v = $p->s3s4($e);                 is $v, $e,    sprintf("%s->s3s4(v) = %s", $p, $e);
            $v = $p->new({ 'address' => $e }); is $v, undef, sprintf("%s->new(v) = undef", $p);
            $v = $p->find($e);                 is $v, undef, sprintf("%s->find(v) = undef", $p);
            $v = $p->is_emailaddress($e);      is $v, 0,     sprintf("%s->is_emailaddress = 0", $p);
        }
        is $p->is_emailaddress(('neko-nyaan' x 25).'@example.jp'), 0;
    }

    UNDISCLOSED: {
        my $r = 'undisclosed-recipient-in-headers@libsisimai.org.invalid';
        my $s = 'undisclosed-sender-in-headers@libsisimai.org.invalid';
        is $p->undisclosed(1), $r, sprintf("%s->undisclosed(1) = %s", $p, $r);
        is $p->undisclosed(0), $s, sprintf("%s->undisclosed(0) = %s", $p, $s);
        is $p->undisclosed(2), $r, sprintf("%s->undisclosed(2) = %s", $p, $r);
        is $p->undisclosed(),  $s, sprintf("%s->undisclosed( ) = %s", $p, $s);
    }
}

done_testing;

