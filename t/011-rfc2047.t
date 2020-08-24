use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC2047;
use Encode;

my $PackageName = 'Sisimai::RFC2047';
my $MethodNames = {
    'class' => [
        'is_mimeencoded', 'mimedecode', 'ctvalue', 'boundary', 'qprintd', 'base64d',
        'levelout', 'makeflat'
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    MIMEDECODE: {
        my $v0  = '';
        my $p1 = 'ASCII TEXT';
        my $p2 = '白猫にゃんこ';
        my $p3 = 'ニュースレター';
        my $b2 = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';
        my $q3 = '=?utf-8?Q?=E3=83=8B=E3=83=A5=E3=83=BC=E3=82=B9=E3=83=AC=E3=82=BF=E3=83=BC?=';

        is $PackageName->is_mimeencoded(\$p1), 0, '->is_mimeencoded = 0';
        is $PackageName->is_mimeencoded(\$p2), 0, '->is_mimeencoded = 0';
        is $PackageName->is_mimeencoded(\$b2), 1, '->is_mimeencoded = 1';
        is $PackageName->is_mimeencoded(\$q3), 1, '->is_mimeencoded = 1';

        for my $e ( $p1, $p2 ) {
            $v0 = $PackageName->mimedecode([$e]);
            $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
            is $v0, $e, '->is_mimedecode = '.$e;
        }

        $v0 = $PackageName->mimedecode([$b2]);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p2, '->is_mimedecode = '.$p2;

        $v0 = $PackageName->mimedecode([$q3]);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p3, '->is_mimedecode = '.$p3;

        # MIME-Encoded text in multiple lines
        my $p4 = '何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。';
        my $b4 = [
            '=?utf-8?B?5L2V44Gn44KC6JaE5pqX44GE44GY44KB44GY44KB44GX44Gf5omA?=',
            '=?utf-8?B?44Gn44OL44Oj44O844OL44Oj44O85rOj44GE44Gm44GE44Gf5LqL?=',
            '=?utf-8?B?44Gg44GR44Gv6KiY5oa244GX44Gm44GE44KL44CC?=',
        ];
        $v0 = $PackageName->mimedecode($b4);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p4, '->is_mimedecode = '.$p4;

        # Other encodings
        my $b5 = [
            '=?Shift_JIS?B?keWK24+8jeKJriAxMJackGyCyYKolIOVqIyUscDZDQo=?=',
            '=?ISO-2022-JP?B?Ym91bmNlSGFtbWVyGyRCJE41IUc9TVdLPhsoQg==?=',
        ];

        for my $e ( @$b5 ) {
            $v0 = $PackageName->mimedecode([$e]);
            $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
            chomp $v0;
            ok length $v0, '->is_mimedecode = '.$v0;
        }
    }

    BASE64D: {
        # Base64, Quoted-Printable
        my $b6 = '44Gr44KD44O844KT';
        my $p6 = 'にゃーん';
        is ${ $PackageName->base64d(\$b6) }, $p6, '->base64d = '.$p6;
        is ${ $PackageName->qprintd(\'=4e=65=6b=6f') }, 'Neko', '->qprintd = Neko';
    }

    QPRINTD: {
        # Part of Quoted-Printable
        my $q7 = '
--971a94f0830fce8d511b5f45b46e17c7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This is the mail delivery agent at messagelabs.com.

I was unable to deliver your message to the following addresses:

maria@dest.example.net

Reason: 550 maria@dest.example.net... No such user

The message subject was: Re: BOAS FESTAS!
The message date was: Tue, 23 Dec 2014 20:39:24 +0000
The message identifier was: DB/3F-17375-60D39495
The message reference was: server-5.tower-143.messagelabs.com!1419367172!32=
691968!1

Please do not reply to this email as it is sent from an unattended mailbox.
Please visit www.messagelabs.com/support for more details
about this error message and instructions to resolve this issue.


--971a94f0830fce8d511b5f45b46e17c7
Content-Type: message/delivery-status

Reporting-MTA: dns; server-15.bemta-3.messagelabs.com
Arrival-Date: Tue, 23 Dec 2014 20:39:34 +0000

--971a94f0830fce8d511b5f45b46e17c7--
        ';
        my $v7 = ${ $PackageName->qprintd(\$q7) };
        ok length $v7, '->qprintd($a)';
        ok length($q7) > length($v7), '->qprintd($a)';
        like $v7, qr|\Q--971a94f0830fce8d511b5f45b46e17c7\E|m, '->qprintd(boundary)';
        unlike $v7, qr|32=$|m, '->qprintd() does not match 32=';

        my $q8 = 'neko';
        is $q8, ${ $PackageName->qprintd(\$q8) };
    }

    CTVALUE: {
        my $c1 = 'multipart/MIXED; boundary="nekochan"; charset=utf-8';
        is $PackageName->ctvalue($c1), 'multipart/mixed', '->ctvalue() = multipart/mixed';
        is $PackageName->ctvalue($c1, 'boundary'), 'nekochan', '->ctvalue(boundary) = nekochan';
        is $PackageName->ctvalue($c1, 'charset'), 'utf-8', '->ctvalue(charset) = utf-8';
        is $PackageName->ctvalue($c1, 'nyaan'), '', '->ctvalue(nyaan) = ""';

        my $c2 = 'QUOTED-PRINTABLE';
        is $PackageName->ctvalue($c2), 'quoted-printable', '->ctvalue() = quoted-printable';
        is $PackageName->ctvalue($c2, 'neko'), '', '->ctvalue("neko") = ""';
    }

    BOUNDARY: {
        my $x1 = 'Content-Type: multipart/mixed; boundary=Apple-Mail-1-526612466';
        my $x2 = 'Apple-Mail-1-526612466';
        is $PackageName->boundary($x1), $x2, '->boundary() = '.$x2;
        is $PackageName->boundary($x1, 0), '--'.$x2, '->boundary(0) = --'.$x2;
        is $PackageName->boundary($x1, 1), '--'.$x2.'--', '->boundary(1) = --'.$x2.'--';
        is $PackageName->boundary($x1, 2), '--'.$x2.'--', '->boundary(2) = --'.$x2.'--';
    }

    HAIRCUT: {
        my $mp = 'Content-Description: "error-message"
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This is the mail delivery agent at messagelabs.com.

I was unable to deliver your message to the following addresses:

maria@dest.example.net

Reason: 550 maria@dest.example.net... No such user';
        my $v1 = $PackageName->haircut(\$mp);
        isa_ok $v1, 'ARRAY';
        is scalar @$v1, 3;

        is $v1->[0], 'text/plain; charset="utf-8"', '->haircut->[0] = text/plain; charset=utf-8';
        is $v1->[1], 'quoted-printable', '->haircut->[1] = quoted-printable';
        ok length $v1->[2];

        my $v2 = $PackageName->haircut(\$mp, 1);
        isa_ok $v2, 'ARRAY';
        is scalar @$v2, 2;
        is $v2->[0], 'text/plain; charset="utf-8"', '->haircut->[0] = text/plain; charset=utf-8';
        is $v2->[1], 'quoted-printable', '->haircut->[1] = quoted-printable';
    }

    LEVELOUT: {
        my $ct = 'multipart/mixed; boundary="b0Nvs+XKfKLLRaP/Qo8jZhQPoiqeWi3KWPXMgw=="';
        my $mp = '
--b0Nvs+XKfKLLRaP/Qo8jZhQPoiqeWi3KWPXMgw==
Content-Description: "error-message"
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This is the mail delivery agent at messagelabs.com.

I was unable to deliver your message to the following addresses:

maria@dest.example.net

Reason: 550 maria@dest.example.net... No such user

The message subject was: Re: BOAS FESTAS!
The message date was: Tue, 23 Dec 2014 20:39:24 +0000
The message identifier was: DB/3F-17375-60D39495
The message reference was: server-5.tower-143.messagelabs.com!1419367172!32=
691968!1

Please do not reply to this email as it is sent from an unattended mailbox.
Please visit www.messagelabs.com/support for more details
about this error message and instructions to resolve this issue.


--b0Nvs+XKfKLLRaP/Qo8jZhQPoiqeWi3KWPXMgw==
Content-Type: message/delivery-status

Reporting-MTA: dns; server-15.bemta-3.messagelabs.com
Arrival-Date: Tue, 23 Dec 2014 20:39:34 +0000

        ';
        my $v1 = $PackageName->levelout($ct, \$mp);
        isa_ok $v1, 'ARRAY';
        is scalar @$v1, 2;

        for my $e ( @$v1 ) {
            isa_ok $e, 'HASH';
            ok length $e->{'head'}->{'content-type'};
            ok length $e->{'body'};
        }
    }

    MAKEFLAT: {
        # multipart/* decoding
        my $h9 = { 'content-type' => 'multipart/report; report-type=delivery-status; boundary="NekoNyaan--------1"' };
        my $p9 = '--NekoNyaan--------1
Content-Type: multipart/related; boundary="NekoNyaan--------2"

--NekoNyaan--------2
Content-Type: multipart/alternative; boundary="NekoNyaan--------3"

--NekoNyaan--------3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

c2lyb25la28K

--NekoNyaan--------3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGh0bWw+CjxoZWFkPgogICAgPHRpdGxlPk5la28gTnlhYW48L3RpdGxlPgo8L2hl
YWQ+Cjxib2R5PgogICAgPGgxPk5la28gTnlhYW48L2gxPgo8L2JvZHk+CjwvaHRt
bD4K

--NekoNyaan--------2
Content-Type: image/jpg

/9j/4AAQSkZJRgABAQEBLAEsAAD/7VaWUGhvdG9zaG9wIDMuMAA4QklNBAwAAAAA
Vk4AAAABAAAArwAAAQAAAAIQAAIQAAAAVjIAGAAB/9j/7gAOQWRvYmUAZAAAAAAB
/9sAhAAGBAQEBQQGBQUGCQYFBgkLCAYGCAsMCgoLCgoMEAwMDAwMDBAMDAwMDAwM
DAwMDAwMDAwMDAwMDAwMDAwMDAwMAQcHBw0MDRgQEBgUDg4OFBQODg4OFBEMDAwM
DBERDAwMDAwMEQwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAEAAK8D
AREAAhEBAxEB/90ABAAW/8QBogAAAAcBAQEBAQAAAAAAAAAABAUDAgYBAAcICQoL

--NekoNyaan--------2
Content-Type: message/delivery-status

Reporting-MTA: dns; example.jp
Received-From-MTA: dns; neko.example.jp
Arrival-Date: Thu, 11 Oct 2018 23:34:45 +0900 (JST)

Final-Recipient: rfc822; kijitora@example.jp
Action: failed
Status: 5.1.1
Diagnostic-Code: User Unknown

--NekoNyaan--------2
Content-Type: message/rfc822

Received: ...

--NekoNyaan--------2--
';
        my $v9 = ${ $PackageName->makeflat($h9->{'content-type'}, \$p9) };
        ok length $v9, '->makeflat($a, $b)';
        ok length($v9) < length($p9), '->makeflat($a, $b)';
        like $v9, qr/sironeko/m, '->makeflat() contains text/plain part';
        unlike $v9, qr/[<]html[>]/m, '->makeflat() does not contain text/html part';
        unlike $v9, qr/4AAQSkZJRgABAQEBLAEsAAD/m, '->makeflat() does not contain base64';
        like $v9, qr/kijitora[@]/m, '->makeflat() contains message/delivery-status part';
        like $v9, qr/Received:/m, '->makeflat() contains message/rfc822 part';
        is $PackageName->makeflat(), undef;
    }

    IRREGULAR_CASE: {
        # Irregular MIME encoded strings
        my $bE = [
            '[NEKO] =?UTF-8?B?44OL44Oj44O844Oz?=',
            '=?UTF-8?B?44OL44Oj44O844Oz?= [NYAAN]',
            '[NEKO] =?UTF-8?B?44OL44Oj44O844Oz?= [NYAAN]'
        ];

        for my $e ( @$bE ) {
            my $vE = $PackageName->mimedecode([$e]);
               $vE = Encode::encode_utf8 $vE if utf8::is_utf8 $vE;
            chomp $vE;

            is $PackageName->is_mimeencoded(\$e), 1, '->is_mimeencoded = 1';
            ok length $vE, '->mimedecode = '.$vE;
            like $vE, qr/ニャーン/, 'Decoded text matches with /ニャーン/';
        }
    }
}

done_testing;
