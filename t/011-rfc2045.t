use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC2045;
use Encode;

my $Package = 'Sisimai::RFC2045';
my $Methods = {
    'class'  => ['is_encoded', 'decodeH', 'parameter', 'boundary', 'decodeQ', 'decodeB', 'levelout', 'makeflat'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    MIMEDECODE: {
        my $v0  = '';
        my $p1 = 'ASCII TEXT';
        my $p2 = '白猫にゃんこ';
        my $p3 = 'ニュースレター';
        my $b2 = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';
        my $q3 = '=?utf-8?Q?=E3=83=8B=E3=83=A5=E3=83=BC=E3=82=B9=E3=83=AC=E3=82=BF=E3=83=BC?=';

        is $Package->is_encoded(\$p1), 0, '->is_encoded = 0';
        is $Package->is_encoded(\$p2), 0, '->is_encoded = 0';
        is $Package->is_encoded(\$b2), 1, '->is_encoded = 1';
        is $Package->is_encoded(\$q3), 1, '->is_encoded = 1';
        is $Package->is_encoded(''), undef;

        for my $e ( $p1, $p2 ) {
            $v0 = $Package->decodeH([$e]);
            $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
            is $v0, $e, '->decodeH = '.$e;
        }

        is $Package->decodeH(''), '';
        $v0 = $Package->decodeH([$b2]);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p2, '->decodeH = '.$p2;

        $v0 = $Package->decodeH([$q3]);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p3, '->decodeH = '.$p3;

        # MIME-Encoded text in multiple lines
        my $p4 = '何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。';
        my $b4 = [
            '=?utf-8?B?5L2V44Gn44KC6JaE5pqX44GE44GY44KB44GY44KB44GX44Gf5omA?=',
            '=?utf-8?B?44Gn44OL44Oj44O844OL44Oj44O85rOj44GE44Gm44GE44Gf5LqL?=',
            '=?utf-8?B?44Gg44GR44Gv6KiY5oa244GX44Gm44GE44KL44CC?=',
        ];
        $v0 = $Package->decodeH($b4);
        $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
        is $v0, $p4, '->decodeH = '.$p4;

        # Other encodings
        my $b5 = [
            '=?Shift_JIS?B?keWK24+8jeKJriAxMJackGyCyYKolIOVqIyUscDZDQo=?=',
            '=?ISO-2022-JP?B?Ym91bmNlSGFtbWVyGyRCJE41IUc9TVdLPhsoQg==?=',
        ];

        for my $e ( @$b5 ) {
            $v0 = $Package->decodeH([$e]);
            $v0 = Encode::encode_utf8 $v0 if utf8::is_utf8 $v0;
            chomp $v0;
            ok length $v0, '->decodeH = '.$v0;
        }
    }

    BASE64D: {
        # Base64, Quoted-Printable
        my $b6 = '44Gr44KD44O844KT';
        my $p6 = 'にゃーん';

        is $Package->decodeB(undef), undef;
        is $Package->decodeQ(undef), undef;
        is ${ $Package->decodeB(\$b6) }, $p6, '->decodeB = '.$p6;
        is ${ $Package->decodeQ(\'=4e=65=6b=6f') }, 'Neko', '->decodeQ = Neko';
    }

    QPRINTD: {
        # Part of Quoted-Printable
        my $q7 = 'I will be traveling for work on July 10-31.  During that time I will have i=
ntermittent access to email and phone, and I will respond to your message a=
s promptly as possible.

Please contact our Client Service Support Team (information below) if you n=
eed immediate assistance on regular account matters, or contact my colleagu=
e Neko Nyaan (neko@example.org; +0-000-000-0000) for all other needs.
';
        my $v7 = ${ $Package->decodeQ(\$q7) };
        ok length $v7, '->decodeQ($a)';
        ok length($q7) > length($v7), '->decodeQ($a)';
        unlike $v7, qr|a=$|m, '->decodeQ() does not match a=';

        my $q8 = 'neko';
        is $q8, ${ $Package->decodeQ(\$q8) };
    }

    CTVALUE: {
        my $c1 = 'multipart/MIXED; boundary="nekochan"; charset=utf-8';
        is $Package->parameter($c1), 'multipart/mixed', '->parameter() = multipart/mixed';
        is $Package->parameter($c1, 'boundary'), 'nekochan', '->parameter(boundary) = nekochan';
        is $Package->parameter($c1, 'charset'), 'utf-8', '->parameter(charset) = utf-8';
        is $Package->parameter($c1, 'nyaan'), '', '->parameter(nyaan) = ""';

        my $c2 = 'QUOTED-PRINTABLE';
        is $Package->parameter($c2), 'quoted-printable', '->parameter() = quoted-printable';
        is $Package->parameter($c2, 'neko'), '', '->parameter("neko") = ""';
    }

    BOUNDARY: {
        my $x1 = 'Content-Type: multipart/mixed; boundary=Apple-Mail-1-526612466';
        my $x2 = 'Apple-Mail-1-526612466';
        is $Package->boundary($x1), $x2, '->boundary() = '.$x2;
        is $Package->boundary($x1, 0), '--'.$x2, '->boundary(0) = --'.$x2;
        is $Package->boundary($x1, 1), '--'.$x2.'--', '->boundary(1) = --'.$x2.'--';
        is $Package->boundary($x1, 2), '--'.$x2.'--', '->boundary(2) = --'.$x2.'--';
    }

    HAIRCUT: {
        my $mp = 'Content-Description: "error-message"
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This is the mail delivery agent at messagelabs.com.

I was unable to deliver your message to the following addresses:

maria@dest.example.net

Reason: 550 maria@dest.example.net... No such user';
        my $v1 = $Package->haircut(\$mp);
        isa_ok $v1, 'ARRAY';
        is scalar @$v1, 3;

        is $v1->[0], 'text/plain; charset="utf-8"', '->haircut->[0] = text/plain; charset=utf-8';
        is $v1->[1], 'quoted-printable', '->haircut->[1] = quoted-printable';
        ok length $v1->[2];

        my $v2 = $Package->haircut(\$mp, 1);
        isa_ok $v2, 'ARRAY';
        is scalar @$v2, 2;
        is $v2->[0], 'text/plain; charset="utf-8"', '->haircut->[0] = text/plain; charset=utf-8';
        is $v2->[1], 'quoted-printable', '->haircut->[1] = quoted-printable';

        is $Package->haircut(undef), undef;
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
        my $v1 = $Package->levelout($ct, \$mp);
        isa_ok $v1, 'ARRAY';
        is scalar @$v1, 2;

        for my $e ( @$v1 ) {
            isa_ok $e, 'ARRAY';
            ok length $e->[0];
            ok length $e->[2];
        }
        isa_ok $Package->levelout('', 'neko'), 'ARRAY';
        isa_ok $Package->levelout('neko', ''), 'ARRAY';
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
        my $v9 = ${ $Package->makeflat($h9->{'content-type'}, \$p9) };
        ok length $v9, '->makeflat($a, $b)';
        ok length($v9) < length($p9), '->makeflat($a, $b)';
        like $v9, qr/sironeko/m, '->makeflat() contains text/plain part';
        unlike $v9, qr/[<]html[>]/m, '->makeflat() does not contain text/html part';
        unlike $v9, qr/4AAQSkZJRgABAQEBLAEsAAD/m, '->makeflat() does not contain base64';
        like $v9, qr/kijitora[@]/m, '->makeflat() contains message/delivery-status part';
        like $v9, qr/Received:/m, '->makeflat() contains message/rfc822 part';
        is $Package->makeflat(undef, undef), undef;
        is $Package->makeflat('neko', undef), undef;
    }

    IRREGULAR_CASE: {
        # Irregular MIME encoded strings
        my $bE = [
            '[NEKO] =?UTF-8?B?44OL44Oj44O844Oz?=',
            '=?UTF-8?B?44OL44Oj44O844Oz?= [NYAAN]',
            '[NEKO] =?UTF-8?B?44OL44Oj44O844Oz?= [NYAAN]'
        ];

        for my $e ( @$bE ) {
            my $vE = $Package->decodeH([$e]);
               $vE = Encode::encode_utf8 $vE if utf8::is_utf8 $vE;
            chomp $vE;

            is $Package->is_encoded(\$e), 1, '->is_encoded = 1';
            ok length $vE, '->decodeH = '.$vE;
            like $vE, qr/ニャーン/, 'Decoded text matches with /ニャーン/';
        }
    }
}

done_testing;
