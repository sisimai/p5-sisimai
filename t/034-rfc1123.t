use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC1123;

my $Package = 'Sisimai::RFC1123';
my $Methods = { 'class'  => ['is_validhostname'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $hostnames0 = [
        '',
        'localhost',
        '127.0.0.1',
        'neko',
        'nyaan.22',
        'mx0.example.22',
        'mx0.example.jp-',
        'mx--0.example.jp',
        'mx..0.example.jp',
        'mx0.example.jp/neko',
    ];
    my $hostnames1 = [
        'mx1.example.jp',
        'mx1.example.jp.',
    ];

    for my $e ( @$hostnames0 ) {
        # Invalid hostnames
        is $Package->is_validhostname($e), 0, '->is_validhostname('.$e.') = 0';
    }

    for my $e ( @$hostnames1 ) {
        # Valid hostnames
        is $Package->is_validhostname($e), 1, '->is_validhostname('.$e.') = 1';
    }
}

done_testing;

