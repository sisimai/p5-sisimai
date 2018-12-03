use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC1894;

my $PackageName = 'Sisimai::RFC1894';
my $MethodNames = {
    'class'  => ['FIELDTABLE', 'FIELDINDEX', 'field', 'match'],
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
        'Diagnostic-Code: SMTP; Unknown user neko@nyaan.jp',
    ];
    my $IsNotDSNField = [
        'Content-Type: message/delivery-status',
        'Subject: Returned mail: see transcript for details',
        'From: Mail Delivery Subsystem <MAILER-DAEMON@neko.example.jp>',
        'Date: Sat, 9 Jun 2018 03:06:57 +0900 (JST)',
    ];
    my $v = undef;

    $v = $PackageName->FIELDTABLE;
    isa_ok $v, 'HASH', '->table returns Hash';
    ok scalar keys %$v, '->FIELDTABLE() returns Hash';

    $v = $PackageName->FIELDINDEX();
    isa_ok $v, 'ARRAY', '->FIELDINDEX() returns Array';
    ok scalar @$v, '->FIELDINDEX() returns Array';
    ok grep { index('Reporting-MTA:', $_) == 0 } @$v;
    ok grep { index('Final-Recipient:', $_) == 0 } @$v;

    $v = $PackageName->FIELDINDEX('mesg');
    isa_ok $v, 'ARRAY', '->FIELDINDEX(mesg) returns Array';
    ok scalar @$v, '->FIELDINDEX(mesg) returns Array';
    ok grep { index('Reporting-MTA:', $_) == 0 } @$v;

    $v = $PackageName->FIELDINDEX('rcpt');
    isa_ok $v, 'ARRAY', '->FIELDINDEX(rcpt) returns Array';
    ok scalar @$v, '->FIELDINDEX(rcpt) returns Array';
    ok grep { index('Final-Recipient:', $_) == 0 } @$v;

    for my $e ( @$RFC1894Field1 ) {
        is $PackageName->match($e), 1, '->match('.$e.') returns 1';
        $v = $PackageName->field($e);
        isa_ok $v, 'ARRAY', '->field('.$e.') returns Array';
        ok grep { index($v->[0], lc($_)) == 0 } @{ $PackageName->FIELDINDEX('mesg') };
        if( $v->[3] eq 'host' ) {
            is $v->[1], 'DNS', 'field->[1] is DNS';
            like $v->[2], qr/[.]/, 'field->[2] includes "."';
        } else {
            is $v->[1], '';
        }
        like $v->[3], qr/(?:host|date)/;
    }

    for my $e ( @$RFC1894Field2 ) {
        is $PackageName->match($e), 2, '->match('.$e.') returns 2';
        $v = $PackageName->field($e);
        isa_ok $v, 'ARRAY', '->field('.$e.') returns Array';
        ok grep { index($v->[0], lc($_)) == 0 } @{ $PackageName->FIELDINDEX('rcpt') };
        if( $v->[3] eq 'host' || $v->[3] eq 'addr' || $v->[3] eq 'code') {
            like $v->[1], qr/(?:DNS|RFC822|SMTP)/, 'field->[1] is DNS or RFC822 or SMTP';
            like $v->[2], qr/[.]/, 'field->[2] includes "."';
        } else {
            is $v->[1], '';
        }
        like $v->[3], qr/(?:host|date|addr|list|stat|code)/;
    }

    for my $e ( @$IsNotDSNField ) {
        is $PackageName->match($e), 0, '->match('.$e.') returns 0';
        $v = $PackageName->field($e);
        is $v, undef, '->field('.$e.') returns undef';
        is $v, undef, '->field returns undef';
    }

}

done_testing;


