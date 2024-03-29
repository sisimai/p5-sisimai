use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::STDIN;

my $Package = 'Sisimai::Mail::STDIN';
my $Methods = {
    'class'  => ['new'],
    'object' => ['path', 'size', 'handle', 'offset', 'read'],
};
my $NewInstance = $Package->new();

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };
isa_ok $NewInstance, $Package;
can_ok $NewInstance, @{ $Methods->{'object'} };
ok $NewInstance->handle->close;

MAKETEST: {

    MAILBOX: {
        my $fakedev = '__SISIMAI_DUMMY_DEVICE_FOR_MAKETEST__';
        my $datatxt = <DATA>; open(STDIN, '>>', $fakedev);
        my $mailbox = $Package->new();
        my $emindex = 0;

        isa_ok $mailbox, $Package;
        can_ok $mailbox, @{ $Methods->{'object'} };
        is $mailbox->path, '<STDIN>', '->path = <STDIN>';
        is $mailbox->size, 0, '->size = 0';
        isa_ok $mailbox->handle, 'IO::Handle';
        is $mailbox->offset, 0, '->offset = 0';

        while( my $r = $mailbox->read ) {
            last;
        }
        ok close(STDIN);
        unlink $fakedev if -e $fakedev;
    }
}

done_testing;

__DATA__
Return-Path: <MAILER-DAEMON@smtpgw.example.jp>
Received: from localhost (localhost)
	by smtpgw.example.jp (V8/cf) id r9G5FZh9018575;
	Wed, 16 Oct 2013 14:15:35 +0900
Date: Wed, 16 Oct 2013 14:15:35 +0900
From: Mail Delivery Subsystem <MAILER-DAEMON@smtpgw.example.jp>
Message-Id: <201310160515.r9G5FZh9018575@smtpgw.example.jp>
To: <kijitora@example.org>
MIME-Version: 1.0
Content-Type: multipart/report; report-type=delivery-status;
	boundary="r9G5FZh9018575.1381900535/smtpgw.example.jp"
Subject: Returned mail: see transcript for details
Auto-Submitted: auto-generated (failure)

This is a MIME-encapsulated message

--r9G5FZh9018575.1381900535/smtpgw.example.jp

The original message was received at Wed, 16 Oct 2013 14:15:34 +0900
from p0000-ipbfpfx00kyoto.kyoto.example.co.jp [192.0.2.25]

   ----- The following addresses had permanent fatal errors -----
<userunknown@bouncehammer.jp>
    (reason: 550 5.1.1 <userunknown@bouncehammer.jp>... User Unknown)

   ----- Transcript of session follows -----
... while talking to mx.bouncehammer.jp.:
>>> DATA
<<< 550 5.1.1 <userunknown@bouncehammer.jp>... User Unknown
550 5.1.1 <userunknown@bouncehammer.jp>... User unknown
<<< 503 5.0.0 Need RCPT (recipient)

--r9G5FZh9018575.1381900535/smtpgw.example.jp
Content-Type: message/delivery-status

Reporting-MTA: dns; smtpgw.example.jp
Received-From-MTA: DNS; p0000-ipbfpfx00kyoto.kyoto.example.co.jp
Arrival-Date: Wed, 16 Oct 2013 14:15:34 +0900

Final-Recipient: RFC822; userunknown@bouncehammer.jp
Action: failed
Status: 5.1.1
Remote-MTA: DNS; mx.bouncehammer.jp
Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@bouncehammer.jp>... User Unknown
Last-Attempt-Date: Wed, 16 Oct 2013 14:15:35 +0900

--r9G5FZh9018575.1381900535/smtpgw.example.jp
Content-Type: message/rfc822

Return-Path: <kijitora@example.org>
Received: from [192.0.2.25] (p0000-ipbfpfx00kyoto.kyoto.example.co.jp [192.0.2.25])
	(authenticated bits=0)
	by smtpgw.example.jp (V8/cf) with ESMTP id r9G5FXh9018568
	for <userunknown@bouncehammer.jp>; Wed, 16 Oct 2013 14:15:34 +0900
From: "Kijitora Cat" <kijitora@example.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Subject: =?utf-8?B?44OQ44Km44Oz44K544Oh44O844Or44Gu44OG44K544OIKOaXpQ==?=
 =?utf-8?B?5pys6KqeKQ==?=
Date: Wed, 16 Oct 2013 14:15:35 +0900
Message-Id: <E1C50F1B-1C83-4820-BC36-AC6FBFBE8568@example.org>
To: userunknown@bouncehammer.jp
Mime-Version: 1.0 (Apple Message framework v1283)
X-Mailer: Apple Mail (2.1283)

5aSq55yJ54yr44CB6K2m5oiS44GX44Gm44Gm44KC54yr44GY44KD44KJ44GX44KS5o+644KJ44Gb
44Gw5a+E44Gj44Gm5p2l44KL44CCDQoNCg==

--r9G5FZh9018575.1381900535/smtpgw.example.jp--


