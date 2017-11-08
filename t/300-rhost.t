use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost';
my $MethodNames = {
    'class' => ['list', 'match', 'get'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->list, 'ARRAY';
    is $PackageName->match, undef;
    is $PackageName->get, undef;

    my $list = $PackageName->list;
    my $host = [
        'aspmx.l.google.com',
        'neko.protection.outlook.com',
        'smtp.secureserver.net',
        'mailstore1.secureserver.net',
        'smtpz4.laposte.net',
        'smtp-in.orange.fr',
    ];

    for my $e ( @$host ) {
        ok $PackageName->match($e), '->match('.$e.')';
        ok grep { $e =~ $_ } @$list;
    }
}

done_testing;

