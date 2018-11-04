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

    my $r = $PackageName->HEADERFIELDS();
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        ok length $e, $e;
        like $e, qr/\A[a-z-]+\z/;
        is $r->{ $e }, 1, $e.' = '.1;
    }

    $r = $PackageName->HEADERFIELDS('date');
    isa_ok $r, 'ARRAY';
    for my $e ( @$r ) {
        ok length $e, $e;
        like $e, qr/\A[A-Za-z-]+\z/;
    }

    $r = $PackageName->HEADERFIELDS('neko');
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        isa_ok $r->{ $e }, 'ARRAY';
        ok scalar @{ $r->{ $e } }, $e.' = '.scalar @{ $r->{ $e } };
        for my $f ( @{ $r->{ $e } } ) {
            ok length $f, $e.'/'.$f;
            like $f, qr/\A[A-Za-z-]+\z/;
        }
    }

    $r = $PackageName->LONGFIELDS;
    isa_ok $r, 'HASH';
    for my $e ( keys %$r ) {
        ok length $e, $e;
        like $e, qr/\A[a-z-]+\z/;
        is $r->{ $e }, 1, $e.' = '.1;
    }

    my $emailaddrs = [
        'neko@example.jp',
        'neko+nyaa@example.jp',
        'nyaa+neko=example.jp@example.org',
        '"neko@nyaan"@example.org',
        '"neko nyaan"@exaple.org',
        '{nekonyaan}@example.org',
        'neko|nyaan@example.org',
        'neko?nyaan@example.org',
        '"neko<>nyaan"@example.org',
        '"neko(nyaan)"@example.org',
        '"nora(:;)neko"@example.org',
        'neko^_^nyaan@example.org',
        'neko$nyaan@example.org',
        'neko%nyaan@example.org',
        'neko&nyaan@example.org',
        'neko?nyaan@example.org',
        'neko|nyaan@example.org',
        '"neko\\nyaan"@example.org',
    ];
    my $isnotaddrs = ['neko', 'neko%example.jp'];
    my $postmaster = [
        'mailer-daemon@example.jp', 
        'MAILER-DAEMON@example.cat',
        'Mailer-Daemon <postmaster@example.org>',
        'MAILER-DAEMON',
        'postmaster',
        'postmaster@example.org',
    ];

    for my $e ( @$emailaddrs ) {
        ok $PackageName->is_emailaddress($e), '->is_emailaddress('.$e.') = 1';
    }

    for my $e ( @$isnotaddrs ) {
        is $PackageName->is_emailaddress($e), 0, '->is_emailaddress('.$e.') = 0';
    }

    ok $PackageName->is_domainpart('example.jp'), '->is_domainpart(example.jp) = 1';
    for my $e ( @$emailaddrs ) {
        is $PackageName->is_domainpart($e), 0, '->is_domainpart('.$e.') = 0';
    }
    is $PackageName->is_domainpart(undef), 0, '->is_domainpart(undef) = 0';
    is $PackageName->is_domainpart('['), 0, '->is_domainpart([) = 0';
    is $PackageName->is_domainpart(')'), 0, '->is_domainpart()) = 0';
    is $PackageName->is_domainpart(';'), 0, '->is_domainpart(;) = 0';

    for my $e ( @$postmaster ) {
        is $PackageName->is_mailerdaemon($e), 1, '->is_mailerdaemon('.$e.') = 1';
    }
    for my $e ( @$emailaddrs ) {
        is $PackageName->is_mailerdaemon($e), 0, '->is_mailerdaemon('.$e.') = 0';
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
        my $v = $PackageName->received($e);
        ok length $e, $e;
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'scalar = '.scalar @$v;
        for my $f ( @$v ) {
            ok length $f, 'received = '.$f;
            ok $f =~ qr/\A[-.0-9A-Za-z]+\z/, 'Regular expression';
        }
    }

    my $rfc822text = <<'EOR';
Return-Path: <shironeko@mx.example.co.jp>
Received: from mx.example.co.jp (localhost [127.0.0.1])
	by mx.example.co.jp (8.13.9/8.13.1) with ESMTP id fffff000000001
	for <kijitora@example.net>; Thu, 9 Apr 2014 23:34:45 +0900
Received: (from shironeko@localhost)
	by mx.example.co.jp (8.13.9/8.13.1/Submit) id fff0000000003
	for kijitora@example.net; Thu, 9 Apr 2014 23:34:45 +0900
Date: Thu, 9 Apr 2014 23:34:45 +0900
Message-Id: <0000000011111.fff0000000003@mx.example.co.jp>
Content-Type: text/plain
MIME-Version: 1.0
From: Shironeko <shironeko@example.co.jp>
To: Kijitora <shironeko@example.co.jp>
Subject: Nyaaaan

Nyaaan
EOR
    my $rfc822part = Sisimai::RFC5322->weedout([split("\n", $rfc822text)]);
    isa_ok $rfc822part, 'SCALAR';
    ok length $$rfc822part;
    like $$rfc822part, qr/^From:/m;
    like $$rfc822part, qr/^Date:/m;
    unlike $$rfc822part, qr/^MIME-Version:/m;
    unlike $$rfc822part, qr/^Received:/m;
}

done_testing;


