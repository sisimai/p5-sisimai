use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC1894;

my $Package = 'Sisimai::RFC1894';
my $Methods = {
    'class'  => ['FIELDINDEX', 'FIELDTABLE', 'field', 'match', 'label'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
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
        'Diagnostic-Code: SMTP; Unknown user neko@nyaan.jp',
    ];
    my $IsNotDSNField = [
        'Content-Type: message/delivery-status',
        'Subject: Returned mail: see transcript for details',
        'From: Mail Delivery Subsystem <MAILER-DAEMON@neko.example.jp>',
        'Date: Sat, 9 Jun 2018 03:06:57 +0900 (JST)',
    ];
    my $v = undef;
    my $q = undef;

    $v = $Package->FIELDINDEX;
    isa_ok $v, 'ARRAY', '->FIELDINDEX() returns ARRAY';
    ok scalar @$v,      '->FIELDINDEX() returns ARRAY';

    $v = $Package->FIELDTABLE;
    isa_ok $v, 'HASH',  '->FIELDTABLE() returns Hash';
    ok scalar keys %$v, '->FIELDTABLE() returns Hash';

    is $Package->field(), undef;
    is $Package->field(1), undef;

    for my $e ( @$RFC1894Field1 ) {
        is $Package->match($e), 1, '->match('.$e.') returns 1';

        $v = $Package->field($e);
        isa_ok $v, 'ARRAY', '->field('.$e.') returns Array';
        if( $v->[3] eq 'host' ) {
            is $v->[1], 'DNS', 'field->[1] is DNS';
            like $v->[2], qr/[.]/, 'field->[2] includes "."';
        } else {
            is $v->[1], '';
        }
        like $v->[3], qr/(?:host|date)/;

        $q = $Package->label($e);
        is $q, $v->[0], '->label returns '.$q;
    }

    for my $e ( @$RFC1894Field2 ) {
        is $Package->match($e), 1, '->match('.$e.') returns 1';

        $v = $Package->field($e);
        isa_ok $v, 'ARRAY', '->field('.$e.') returns Array';
        if( $v->[3] eq 'host' || $v->[3] eq 'addr' || $v->[3] eq 'code') {
            like $v->[1], qr/(?:DNS|RFC822|SMTP)/, 'field->[1] is DNS or RFC822 or SMTP';
            like $v->[2], qr/[.]/, 'field->[2] includes "."';
        } else {
            is $v->[1], '';
        }
        like $v->[3], qr/(?:host|date|addr|list|stat|code)/;

        $q = $Package->label($e);
        is $q, $v->[0], '->label returns '.$q;
    }

    for my $e ( @$IsNotDSNField ) {
        is $Package->match($e), 0, '->match('.$e.') returns 0';

        $v = $Package->field($e);
        is $v, undef, '->field('.$e.') returns undef';

        $q = $Package->label($e);
        ok $q, '->label returns '.$q;
    }
}

done_testing;


