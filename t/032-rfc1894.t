use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC1894;

my $PackageName = 'Sisimai::RFC1894';
my $MethodNames = {
    'class'  => ['table', 'match', 'field'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $RFC1894Field1 = [
        'Reporting-MTA: dns; neko.example.jp',
        'Received-From-MTA: dns; mx.libsisimai.org',
        'Arrival-Date: Sun, 3 Jun 2018 14:22:02 +0900 (JST)',
    ];
    my $RFC1894Field2 = [
        'Final-Recipient: RFC822; kijitora@neko.example.jp',
        'X-Actual-Recipient: RFC822; sironeko@nyaan.jp',
        'Original-Recipient: RFC822; kuroneko@libsisimai.org',
        'Action: failed',
        'Status: 4.4.7',
        'Remote-MTA: DNS; [127.0.0.1]',
        'Last-Attempt-Date: Sat, 9 Jun 2018 03:06:57 +0900 (JST)',
    ];
    my $IsNotDSNField = [
        'Content-Type: message/delivery-status',
        'Subject: Returned mail: see transcript for details',
        'From: Mail Delivery Subsystem <MAILER-DAEMON@neko.example.jp>',
        'Date: Sat, 9 Jun 2018 03:06:57 +0900 (JST)',
    ];
    my $v = $PackageName->table;

    isa_ok $v, 'HASH', '->table returns Hash';
    ok scalar keys %$v, '->table returns Hash';
}

done_testing;


