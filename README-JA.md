![](https://libsisimai.org/static/images/logo/sisimai-x01.png)

[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/sisimai/p5-sisimai/blob/master/LICENSE)
[![Coverage Status](https://img.shields.io/coveralls/sisimai/p5-sisimai.svg)](https://coveralls.io/r/sisimai/p5-sisimai)
[![Perl](https://img.shields.io/badge/perl-v5.10--v5.34-blue.svg)](https://www.perl.org)
[![CPAN](https://img.shields.io/badge/cpan-v4.25.16-blue.svg)](https://metacpan.org/pod/Sisimai)

> [!IMPORTANT]
> **2024年2月2日の時点でこのリポジトリのデフォルトブランチは[5-stable](https://github.com/sisimai/p5-sisimai/tree/5-stable)
> (Sisimai 5)になりました。** もし古いバージョンを使いたい場合は[4-stable](https://github.com/sisimai/p5-sisimai/tree/4-stable)
> ブランチを見てください。また`main`や`master`ブランチはもうこのリポジトリでは使用していません。

> [!CAUTION]
> **Sisimai 4.25.14p11およびそれ以前のバージョンには 正規表現に関する脆弱性
> [ReDoS: CVE-2022-4891](https://jvndb.jvn.jp/ja/contents/2022/JVNDB-2022-005663.html)があります。
> 該当するバージョンをお使いの場合はv4.25.14p12以降へアップグレードしてください。**

> [!WARNING]
> Sisimai 5はPerl 5.26以上が必要です。インストール/アップグレードを実行する前に`perl -v`コマンドで
> システムに入っているPerlのバージョンを確認してください。

- [**README(English)**](README.md)
- [シシマイ? | What is Sisimai](#what-is-sisimai)
    - [主な特徴的機能 | Key features](#key-features)
    - [コマンドラインでのデモ | command line demo](#command-line-demo)
- [シシマイを使う準備 | Setting Up Sisimai](#setting-up-sisimai)
    - [動作環境 | System requirements](#system-requirements)
    - [インストール | Install](#install)
        - [CPANから | From CPAN](#from-cpan)
        - [GitHubから | From GitHub](#from-github)
- [使い方 | Usage](#usage)
    - [基本的な使い方 | Basic usage](#basic-usage)
    - [解析結果をJSONで得る | Convert to JSON](#convert-to-json)
    - [コールバック機能 | Callback feature](#callback-feature)
    - [ワンライナー | One-Liner](#one-liner)
    - [出力例 | Output example](#output-example)
- [シシマイの仕様 | Sisimai Specification](#sisimai-specification)
    - [bounceHammerとSisimaiの違い | Differences](#differences-between-bouncehammer-and-sisimai)
    - [その他の仕様詳細 | Other specification of Sisimai](#other-spec-of-sisimai)
- [Contributing](#contributing)
    - [バグ報告 | Bug report](#bug-report)
    - [解析できないメール | Emails could not be parsed](#emails-could-not-be-parsed)
- [その他の情報 | Other Information](#other-information)
    - [関連サイト | Related sites](#related-sites)
    - [参考情報 | See also](#see-also)
- [作者 | Author](#author)
- [著作権 | Copyright](#copyright)
- [ライセンス | License](#license)

What is sisimai
===============================================================================
Sisimai(シシマイ)はRFC5322準拠のエラーメールを解析し、解析結果をデータ構造に
変換するインターフェイスを提供するPerlモジュールです。
__シシマイ__ はbounceHammer version 4として開発していたものであり、Version 4なので
__シ(Si)__ から始まりマイ(MAI: __Mail Analyzing Interface__)を含む名前になりました。

![](https://libsisimai.org/static/images/figure/sisimai-overview-1.png)

Key features
-------------------------------------------------------------------------------
* __エラーメールをデータ構造に変換__
  * Perlのデータ形式(HashとArray)とJSON(文字列)に対応
* __インストールも使用も簡単__
  * `cpan`, `cpanm`, `cpm install`
  * git clone & make
* __高い解析精度__
  * 解析精度はbounceHammerの2倍
  * 68種類のMTA/MDA/ESPに対応
  * Feedback Loopにも対応
  * 29種類のエラー理由を検出
* __bounceHammer 2.7.13p3よりも高速に解析__
  * 2.0倍程高速

Command line demo
-------------------------------------------------------------------------------
次の画像のように、Perl版シシマイ(p5-sisimai)もRuby版シシマイ(rb-sisimai)も、
コマンドラインから簡単にバウンスメールを解析することができます。
![](https://libsisimai.org/static/images/demo/sisimai-dump-01.gif)

Setting Up Sisimai
===============================================================================

System requirements
-------------------------------------------------------------------------------

シシマイの動作環境についての詳細は
[Sisimai | シシマイを使ってみる](https://libsisimai.org/ja/start/)をご覧ください。

* [Perl 5.10.1 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)


Install
-------------------------------------------------------------------------------
### From CPAN
```shell
$ cpanm --sudo Sisimai
--> Working on Sisimai
Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.25.16.tar.gz ... OK
...
1 distribution installed
$ perldoc -l Sisimai
/usr/local/lib/perl5/site_perl/5.30.0/Sisimai.pm
```

### From GitHub
```shell
$ cd /usr/local/src
$ git clone https://github.com/sisimai/p5-sisimai.git
$ cd ./p5-sisimai
$ sudo make install-from-local
--> Working on .
Configuring Sisimai-4.25.16 ... OK
1 distribution installed
```

Usage
===============================================================================

Basic usage
-------------------------------------------------------------------------------
下記のようにSisimaiの`make()`メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が配列リファレンスで返ってきます。v4.25.6から元データとなった電子メール
ファイルへのPATHを保持する`origin`が利用できます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $v = Sisimai->make('/path/to/mbox'); # or path to Maildir/

# Beginning with v4.23.0, both make() and dump() method of Sisimai class can
# read bounce messages from variable instead of a path to mailbox
use IO::File;
my $r = '';
my $f = IO::File->new('/path/to/mbox'); # or path to Maildir/
{ local $/ = undef; $r = <$f>; $f->close }
my $v = Sisimai->make(\$r);

# If you want to get bounce records which reason is "delivered", set "delivered"
# option to make() method like the following:
my $v = Sisimai->make('/path/to/mbox', 'delivered' => 1);

if( defined $v ) {
    for my $e ( @$v ) {
        print ref $e;                   # Sisimai::Data
        print ref $e->recipient;        # Sisimai::Address
        print ref $e->timestamp;        # Sisimai::Time

        print $e->addresser->address;   # shironeko@example.org # From
        print $e->recipient->address;   # kijitora@example.jp   # To
        print $e->recipient->host;      # example.jp
        print $e->deliverystatus;       # 5.1.1
        print $e->replycode;            # 550
        print $e->reason;               # userunknown
        print $e->origin;               # /var/spool/bounce/new/1740074341.eml

        my $h = $e->damn();             # Convert to HASH reference
        my $j = $e->dump('json');       # Convert to JSON string
        print $e->dump('json');         # JSON formatted bounce data
    }
}
```

Convert to JSON
-------------------------------------------------------------------------------
下記のようにSisimaiの`dump()`メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が文字列(JSON)で返ってきます。

```perl
# Get JSON string from parsed mailbox or Maildir/
my $j = Sisimai->dump('/path/to/mbox'); # or path to Maildir/
                                        # dump() is added in v4.1.27
print $j;                               # parsed data as JSON

# dump() method also accepts "delivered" option like the following code:
my $j = Sisimai->dump('/path/to/mbox', 'delivered' => 1);
```

Callback feature
-------------------------------------------------------------------------------
Sisimai 4.19.0から`Sisimai->make()`と`Sisimai->dump()`にコードリファレンスを
引数`hook`に指定できるコールバック機能が実装されました。
`hook`に指定したサブルーチンによって処理された結果は`Sisimai::Data->catch`
メソッドで得ることができます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $callbackto = sub {
    my $emdata = shift;
    my $caught = { 'x-mailer' => '', 'queue-id' => '' };

    if( $emdata->{'message'} =~ m/^X-Postfix-Queue-ID:\s*(.+)$/m ) {
        $caught->{'queue-id'} = $1;
    }

    $caught->{'x-mailer'} = $emdata->{'headers'}->{'x-mailer'} || '';
    return $caught;
};
my $data = Sisimai->make('/path/to/mbox', 'hook' => $callbackto);
my $json = Sisimai->dump('/path/to/mbox', 'hook' => $callbackto);

print $data->[0]->catch->{'x-mailer'};    # Apple Mail (2.1283)
```

コールバック機能のより詳細な使い方は
[Sisimai | 解析方法 - コールバック機能](https://libsisimai.org/ja/usage/#callback)
をご覧ください。

One-Liner
-------------------------------------------------------------------------------
Sisimai 4.1.27から登場した`dump()`メソッドを使うとワンライナーでJSON化した
解析結果が得られます。

```shell
$ perl -MSisimai -lE 'print Sisimai->dump(shift)' /path/to/mbox
```

Output example
-------------------------------------------------------------------------------
![](https://libsisimai.org/static/images/demo/sisimai-dump-02.gif)

```json
[{"listid": "","senderdomain": "example.com","replycode": "550","origin": "set-of-emails/maildir/bsd/lhost-office365-13.eml","smtpagent": "Office365","smtpcommand": "","timestamp": 1493541285,"diagnostictype": "SMTP","action": "failed","feedbacktype": "","lhost": "omls-1.kuins.neko.example.jp","timezoneoffset": "+0000","recipient": "kijitora-nyaan@neko.kyoto.example.jp","token": "3ea52cc68fa4ce73b0489a01e33f53477968252f","destination": "neko.kyoto.example.jp","addresser": "neko@example.com","diagnosticcode": "Error Details Reported error: 550 5.1.10 RESOLVER.ADR.RecipientNotFound; Recipient not found by SMTP address lookup DSN generated by: NEKONYAAN0022.apcprd01.prod.exchangelabs.com","softbounce": 0,"catch": {"x-mailer": "","sender": "","queue-id": ""},"messageid": "","deliverystatus": "5.1.10","rhost": "nekonyaan0022.apcprd01.prod.exchangelabs.com","subject": "にゃーん","alias": "","reason": "userunknown"}]
```

Sisimai Specification
===============================================================================

Differences between bounceHammer and Sisimai
-------------------------------------------------------------------------------
bounceHammer 2.7.13p3とSisimai(シシマイ)は下記のような違いがあります。
違いの詳細については[Sisimai | 違いの一覧](https://libsisimai.org/ja/diff/)
をご覧ください。

| 機能                                           | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| 動作環境(Perl)                                 | 5.10 - 5.14   | 5.10 - 5.38 |
| コマンドラインツール                           | あり          | 無し        |
| 商用MTAとMSP対応解析モジュール                 | 無し          | あり(同梱)  |
| WebUIとAPI                                     | あり          | 無し        |
| 解析済バウンスデータを保存するDBスキーマ       | あり          | 無し[1]     |
| 解析精度の割合(2000通のメール)[2]              | 0.61          | 1.00        |
| メール解析速度(1000通のメール)                 | 4.24秒        | 1.35秒[3]   |
| 検出可能なバウンス理由の数                     | 19            | 29          |
| 解析エンジン(MTAモジュール)の数                | 15            | 68          |
| 2件以上のバウンスがあるメールの解析            | 1件目だけ     | 全件解析可能|
| FeedBack Loop/ARF形式のメール解析              | 非対応        | 対応済      |
| 宛先ドメインによる分類項目                     | あり          | 無し        |
| 解析結果の出力形式                             | YAML,JSON,CSV | JSON        |
| インストール作業が簡単かどうか                 | やや面倒      | 簡単で楽    |
| cpan, cpanm, cpmコマンドでのインストール       | 非対応        | 対応済      |
| 依存モジュール数(Perlのコアモジュールを除く)   | 24モジュール  | 2モジュール |
| LOC:ソースコードの行数                         | 18200行       | 10800行     |
| テスト件数(t/,xt/ディレクトリ)                 | 27365件       | 270000件    |
| ライセンス                                     | GPLv2かPerl   | 二条項BSD   |
| 開発会社によるサポート契約                     | 終売(EOS)     | 提供中      |

1. DBIまたは好きなORMを使って自由に実装してください
2. [./ANALYTICAL-PRECISION](https://github.com/sisimai/p5-sisimai/blob/master/ANALYTICAL-PRECISION)を参照
3. Xeon E5-2640 2.5GHz x 2 cores | 5000 bogomips | 1GB RAM | Perl 5.24.1

Other spec of Sisimai
-------------------------------------------------------------------------------
- [**解析モジュールの一覧**](https://libsisimai.org/ja/engine/)
- [**バウンス理由の一覧**](https://libsisimai.org/ja/reason/)
- [**Sisimai::Dataのデータ構造**](https://libsisimai.org/ja/data/)

Contributing
===============================================================================

Bug report
-------------------------------------------------------------------------------
もしもSisimaiにバグを発見した場合は[Issues](https://github.com/sisimai/p5-sisimai/issues)
にて連絡をいただけると助かります。

Emails could not be parsed
-------------------------------------------------------------------------------
Sisimaiで解析できないバウンスメールは
[set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet](https://github.com/sisimai/set-of-emails/tree/master/to-be-debugged-because/sisimai-cannot-parse-yet)リポジトリに追加してPull-Requestを送ってください。


Other Information
===============================================================================

Related sites
-------------------------------------------------------------------------------
* __@libsisimai__ | [Sisimai on Twitter (@libsisimai)](https://twitter.com/libsisimai)
* __LIBSISIMAI.ORG__ | [SISIMAI | MAIL ANALYZING INTERFACE | DECODING BOUNCES, BETTER AND FASTER.](https://libsisimai.org/)
* __Sisimai Blog__ | [blog.libsisimai.org](http://blog.libsisimai.org/)
* __Facebook Page__ | [facebook.com/libsisimai](https://www.facebook.com/libsisimai/)
* __GitHub__ | [github.com/sisimai/p5-sisimai](https://github.com/sisimai/p5-sisimai)
* __CPAN__ | [Sisimai - Mail Analyzing Interface for bounce mails. - metacpan.org](https://metacpan.org/pod/Sisimai)
* __CPAN Testers Reports__ | [CPAN Testers Reports: Reports for Sisimai](http://cpantesters.org/distro/S/Sisimai.html)
* __Ruby verson__ | [Ruby version of Sisimai](https://github.com/sisimai/rb-sisimai)
* __Fixtures__ | [set-of-emails - Sample emails for "make test"](https://github.com/sisimai/set-of-emails)
* __bounceHammer.JP__ | [bounceHammer will be EOL on February 29, 2016](http://bouncehammer.jp/)

See also
-------------------------------------------------------------------------------
* [README.md - README.md in English](https://github.com/sisimai/p5-sisimai/blob/master/README.md)
* [RFC3463 - Enhanced Mail System Status Codes](https://tools.ietf.org/html/rfc3463)
* [RFC3464 - An Extensible Message Format for Delivery Status Notifications](https://tools.ietf.org/html/rfc3464)
* [RFC3834 - Recommendations for Automatic Responses to Electronic Mail](https://tools.ietf.org/html/rfc3834)
* [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC5322 - Internet Message Format](https://tools.ietf.org/html/rfc5322)

Author
===============================================================================
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

Copyright
===============================================================================
Copyright (C) 2014-2024 azumakuniyuki, All Rights Reserved.

License
===============================================================================
This software is distributed under The BSD 2-Clause License.

