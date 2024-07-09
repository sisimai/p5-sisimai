use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;

my $Package = 'Sisimai::Message';
my $Methods = { 'class'  => ['rise', 'sift', 'part', 'makemap', 'tidy'] };
my $Mailbox = './set-of-emails/mailbox/mbox-0';

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    use IO::File;
    my $filehandle = IO::File->new($Mailbox, 'r');
    my $mailastext = '';
    my $callbackto = sub {
        my $argvs = shift;
        my $catch = { 
            'x-mailer' => '',
            'return-path' => '',
        };
        $catch->{'from'} = $argvs->{'headers'}->{'from'} || '';
        $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
        $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
        return $catch;
    };

    while( my $r = <$filehandle> ) {
        $mailastext .= $r;
    }
    $filehandle->close;
    ok length $mailastext;

    is $Package->rise(), undef;
    is $Package->rise({}), undef;

    my $p = $Package->rise({ 'data' => $mailastext });
    isa_ok $p, 'HASH';
    isa_ok $p->{'header'}, 'HASH', '->header';
    isa_ok $p->{'ds'}, 'ARRAY', '->ds';
    isa_ok $p->{'rfc822'}, 'HASH', '->rfc822';
    ok length $p->{'from'}, $p->{'from'};

    $p = $Package->rise({ 'data' => $mailastext, 'hook' => $callbackto });

    for my $e ( @{ $p->{'ds'} } ) {
        is $e->{'spec'}, 'SMTP', '->spec = SMTP';
        like $e->{'recipient'}, qr/[@]/, '->recipient = '.$e->{'recipient'};
        like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
        ok exists $e->{'command'}, '->command = '.$e->{'command'};
        like $e->{'date'}, qr/\d{4}/, '->date = '.$e->{'date'};
        ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
        ok length $e->{'action'}, '->action = '.$e->{'action'};
        ok length $e->{'rhost'}, '->rhost = '.$e->{'rhost'};
        ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};

        for my $q ( 'rhost', 'lhost' ) {
            next unless $e->{ $q };
            like $e->{ $q }, qr/\A.+[.].+\z/, '->'.$q.' = '.$e->{ $q };
        }
        is $e->{'agent'}, 'Sendmail', '->agent = '.$e->{'agent'};
    }

    for my $e ( 'content-type', 'to', 'subject', 'date', 'from', 'message-id' ) {
        my $h = $p->{'header'}->{ $e };
        ok length $h, $h;
    }
    isa_ok $p->{'header'}->{'received'}, 'ARRAY';

    for my $e ( qw|return-path to subject date from message-id| ) {
        my $h = $p->{'rfc822'}->{ $e };
        ok length $h, $e;
    }

    isa_ok $p->{'catch'}, 'HASH';
    ok defined $p->{'catch'}->{'x-mailer'};
    ok defined $p->{'catch'}->{'return-path'};
    ok defined $p->{'catch'}->{'from'};

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

    TIDY: {
        my $tidiedtext = $Package->tidy(\$rfc822body);
        isa_ok $tidiedtext, 'SCALAR';
        ok length $$tidiedtext;
        like   $$tidiedtext, qr{Content-Type: text/plain};
        unlike $$tidiedtext, qr{content-type:   };
        is $Package->tidy(''), '';
    }

    PART: {
        is $Package->part(), undef;
        is $Package->part(undef), undef;
    }

    MAKEMAP: {
        isa_ok $Package->makemap(''), 'HASH';
    }

    SIFT: {
        is $Package->sift('mail' => {}), undef;
        is $Package->sift('mail' => {'header' => {}}), undef;
    }
}

done_testing;

