use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC5322;

my $Package = 'Sisimai::RFC5322';
my $Methods = {
    'class'  => ['HEADERFIELDS', 'LONGFIELDS', 'FIELDINDEX', 'received', 'part'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $r = undef;

    $r = $Package->HEADERFIELDS();
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        ok length $e, $e;
        like $e, qr/\A[a-z-]+\z/;
        is $r->{ $e }, 1, $e.' = '.1;
    }

    $r = $Package->HEADERFIELDS('date');
    isa_ok $r, 'ARRAY';
    for my $e ( @$r ) {
        ok length $e, $e;
        like $e, qr/\A[a-z-]+\z/;
    }

    $r = $Package->HEADERFIELDS('neko');
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        isa_ok $r->{ $e }, 'ARRAY';
        ok scalar @{ $r->{ $e } }, $e.' = '.scalar @{ $r->{ $e } };
        for my $f ( @{ $r->{ $e } } ) {
            ok length $f, $e.'/'.$f;
            like $f, qr/\A[a-z-]+\z/;
        }
    }

    $r = $Package->LONGFIELDS;
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        ok length $e, $e;
        like $e, qr/\A[a-z-]+\z/;
        is $r->{ $e }, 1, $e.' = '.1;
    }

    $r = $Package->FIELDINDEX;
    isa_ok $r, 'ARRAY';
    for my $e ( @$r ) {
        ok length $e, $e;
        like $e, qr/\A[A-Z][A-Za-z-]+\z/;
    }

    # Check the value of Received header
    my $received00 = [
        'from mx.example.org (c182128.example.net [192.0.2.128]) by mx.example.jp (8.14.4/8.14.4) with ESMTP id oBB3JxRJ022484 for <shironeko@example.jp>; Sat, 11 Dec 2010 12:20:00 +0900 (JST)',
        'from localhost (localhost [127.0.0.1]) (ftp://ftp.isi.edu/in-notes/rfc1894.txt) by marutamachi.example.org with dsn; Sat, 11 Dec 2010 12:19:59 +0900',
        'from [127.0.0.1] (c10920.example.com [192.0.2.20]) by marutamachi.example.org with SMTP; Sat, 11 Dec 2010 12:19:17 +0900 id 0EFECD4E.4D02EDD9.0000C5BA',
        'from host (HELO exchange.example.co.jp) (192.0.2.57) by 0 with SMTP; 29 Apr 2007 23:19:00 -0000',
        'from mail by marutamachi.example.org with local (Exim 4.72) id 1X58pT-0004bZ-Co for shironeko@example.jp; Thu, 10 Jul 2014 16:31:43 +0900',
        'from mail4.example.co.jp (1234c.example.com [192.0.2.1]) by mx.example.jp (8.14.4/8.14.4) with ESMTP id r4B0078w00000 for <postmaster@example.jp>; Mon, 11 #May 2013 00:00:00 +0900 (JST)',
        '(from webmaster@localhost) by mail4.example.co.jp (8.14.4/8.14.4/Submit) id r4B003v000000 for shironeko@example.ne.jp; Mon, 11 May 2013 00:00:00 +0900',
        'from biglobe.ne.jp by rcpt-expgw4.biglobe.ne.jp (0000/0000000000) with SMTP id p0000000000000 for <kijitora@mx.example.com>; Thu, 11 Feb 2014 00:00:00 +090#0',
        'from wfilter115 (wfilter115-a0 [172.26.26.68]) by wsmtpr24.ezweb.ne.jp (EZweb Mail) with ESMTP id EF283A071 for <user@example.or.jp>; Sun,  7 Sep 2008 21:4#0:12 +0900 (JST)',
        'from vagrant-centos65.example.com (c213502.kyoto.example.ne.jp [192.0.2.135]) by aneyakoji.example.jp (V8/cf) with ESMTP id s6HB0VsJ028505 for <kijitora@ex#ample.jp>; Thu, 17 Jul 2014 20:00:32 +0900',
        'from localhost (localhost [local]); by localhost (OpenSMTPD) with ESMTPA id 1e2a9eaa; for <kijitora@example.jp>;',
        'from [127.0.0.1] (unknown [172.25.191.1]) by smtp.example.com (Postfix) with ESMTP id 7874F1FB8E; Sat, 21 Jun 2014 18:34:34 +0000 (UTC)',
        'from unknown (HELO ?127.0.0.1?) (172.25.73.1) by 172.25.73.144 with SMTP; 1 Jul 2014 08:30:40 -0000',
        'from [192.0.2.25] (p0000-ipbfpfx00kyoto.kyoto.example.co.jp [192.0.2.25]) (authenticated bits=0) by smtpgw.example.jp (V8/cf) with ESMTP id r9G5FXh9018568',
        'from localhost (localhost) by nijo.example.jp (V8/cf) id s1QB5ma0018057; Wed, 26 Feb 2014 06:05:48 -0500',
        'by 10.194.5.104 with SMTP id r8csp190892wjr; Fri, 18 Jul 2014 00:31:04 -0700 (PDT)',
        'from gargamel.example.com (192.0.2.146) by athena.internal.example.com with SMTP; 12 Jun 2013 02:22:14 -0000',
    ];

    for my $e ( @$received00 ) {
        # Check each value returned from Sisimai::RFC5322->received
        # 0: (from)   "hostname"
        # 1: (by)     "hostname"
        # 2: (via)    "protocol/tcp"
        # 3: (with)   "protocol/smtp"
        # 4: (id)     "queue-id"
        # 5: (for)    "envelope-to address"
        my $v = $Package->received($e);
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'scalar = '.scalar @$v;
        is scalar @$v, 6;
        like $v->[0], qr/\A[^\s\(\)\[\];]+\z/, '->received(from) = '.$v->[0] if length $v->[0];
        like $v->[1], qr/\A[^\s\(\)\[\];]+\z/, '->received(by) = '.$v->[1]   if length $v->[1];
        is   $v->[2], '',                      '->received(via) = ""';
        like $v->[3], qr/\A[^\s;]+\z/,         '->received(with) = '.$v->[3] if length $v->[3];
        like $v->[4], qr/\A[^\s;]+\z/,         '->received(id) = '.$v->[4]   if length $v->[4];
        like $v->[5], qr/[^\s;]+[@][^\s;]+/,   '->received(for) = '.$v->[5]  if length $v->[5];
    }

    my $rfc822body = <<'EOB';
This is a MIME-encapsulated message

The original message was received at Thu, 9 Apr 2014 23:34:45 +0900
from localhost [127.0.0.1]

   ----- The following addresses had permanent fatal errors -----
<kijitora@example.net>
    (reason: 551 not our customer)

   ----- Transcript of session follows -----
... while talking to mx-0.neko.example.jp.:
<<< 450 busy - please try later
... while talking to mx-1.neko.example.jp.:
>>> DATA
<<< 551 not our customer
550 5.1.1 <kijitora@example.net>... User unknown
<<< 503 need RCPT command [data]

Content-Type: message/delivery-status
Reporting-MTA: dns; mx.example.co.jp
Received-From-MTA: DNS; localhost
Arrival-Date: Thu, 9 Apr 2014 23:34:45 +0900

Final-Recipient: RFC822; kijitora@example.net
Action: failed
Status: 5.1.6
Remote-MTA: DNS; mx-s.neko.example.jp
Diagnostic-Code: SMTP; 551 not our customer
Last-Attempt-Date: Thu, 9 Apr 2014 23:34:45 +0900

Content-Type: message/rfc822
Return-Path: <shironeko@mx.example.co.jp>
Received: from mx.example.co.jp (localhost [127.0.0.1])
	by mx.example.co.jp (8.13.9/8.13.1) with ESMTP id fffff000000001
	for <kijitora@example.net>; Thu, 9 Apr 2014 23:34:45 +0900
Received: (from shironeko@localhost)
	by mx.example.co.jp (8.13.9/8.13.1/Submit) id fff0000000003
	for kijitora@example.net; Thu, 9 Apr 2014 23:34:45 +0900
Date: Thu, 9 Apr 2014 23:34:45 +0900
Message-Id: <0000000011111.fff0000000003@mx.example.co.jp>
content-type:       text/plain
MIME-Version: 1.0
From: Shironeko <shironeko@example.co.jp>
To: Kijitora <shironeko@example.co.jp>
Subject: Nyaaaan

Nyaaan

__END_OF_EMAIL_MESSAGE__
EOB
    my $emailpart1 = $Package->part(\$rfc822body, ['Content-Type: message/rfc822']);
    isa_ok $emailpart1, 'ARRAY';
    is scalar(@$emailpart1), 2;
    ok length $emailpart1->[0];
    ok length $emailpart1->[1];
    like $emailpart1->[0], qr/^Final-Recipient: /m;
    like $emailpart1->[1], qr/^Subject: /m;
    unlike $emailpart1->[0], qr/^Return-Path: /m;
    unlike $emailpart1->[0], qr/binary$/m;
    unlike $emailpart1->[1], qr/^Remote-MTA: /m;
    unlike $emailpart1->[1], qr/^Neko-Nyaan/m;

    my $emailpart2 = $Package->part(\$rfc822body, ['Content-Type: message/rfc822'], 1);
    isa_ok $emailpart1, 'ARRAY';
    is scalar(@$emailpart1), 2;
    ok length $emailpart1->[0];
    ok length $emailpart1->[1];
    like $emailpart1->[0], qr/^Final-Recipient: /m;
    like $emailpart1->[1], qr/^Subject: /m;
    unlike $emailpart1->[0], qr/^Return-Path: /m;
    unlike $emailpart1->[0], qr/binary$/m;
    unlike $emailpart1->[1], qr/^Remote-MTA: /m;
    unlike $emailpart1->[1], qr/^Neko-Nyaan/m;

    ok length($emailpart1->[1]) < length($emailpart2->[1]);

}

done_testing;

