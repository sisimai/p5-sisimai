use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC5322;

my $PackageName = 'Sisimai::RFC5322';
my $MethodNames = {
    'class' => [ 
        'is_emailaddress', 'is_domainpart', 'is_mailerdaemon', 'received'
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $ismailaddr = 'neko@example.jp';
    my $nomailaddr = 'neko';
    my $subaddress = 'neko+nyaa@example.jp';
    my $verpstring = 'nyaa+neko=example.jp@example.org';
    my $postmaster = 'mailer-daemon@example.jp';

    ok $PackageName->is_emailaddress( $ismailaddr ), '->is_emailaddress = 1';
    is $PackageName->is_emailaddress( $nomailaddr ), 0, '->is_emailaddress = 0';

    ok $PackageName->is_domainpart( 'example.jp' ), '->is_domainpart(example.jp) = 1';
    is $PackageName->is_domainpart( $ismailaddr ), 0, '->is_domainpart('.$ismailaddr.') = 0';
    is $PackageName->is_domainpart( undef ), 0, '->is_domainpart(undef) = 0';
    is $PackageName->is_domainpart( '[' ), 0, '->is_domainpart([) = 0';
    is $PackageName->is_domainpart( ')' ), 0, '->is_domainpart()) = 0';
    is $PackageName->is_domainpart( ';' ), 0, '->is_domainpart(;) = 0';

    ok $PackageName->is_mailerdaemon( $postmaster), '->is_mailerdaemon = 1';
    is $PackageName->is_mailerdaemon( $ismailaddr), 0, '->is_mailerdaemon = 0';

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
        my $v = $PackageName->received( $e );
        ok length $e, $e;
        isa_ok $v, 'ARRAY';
        ok scalar @$v, 'scalar = '.scalar @$v;
        for my $f ( @$v ) {
            ok length $f, 'received = '.$f;
            ok $f =~ qr/\A[-.0-9A-Za-z]+\z/, 'Regular expression';
        }
    }
    
}

done_testing;

