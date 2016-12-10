[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/sisimai/p5-Sisimai/blob/master/LICENSE)
[![Coverage Status](https://img.shields.io/coveralls/sisimai/p5-Sisimai.svg)](https://coveralls.io/r/sisimai/p5-Sisimai)
[![Build Status](https://travis-ci.org/sisimai/p5-Sisimai.svg?branch=master)](https://travis-ci.org/sisimai/p5-Sisimai) 
[![Perl](https://img.shields.io/badge/perl-v5.10--v5.22-blue.svg)](https://www.perl.org)
[![CPAN](https://img.shields.io/badge/cpan-v4.19.0-blue.svg)](https://metacpan.org/pod/Sisimai)

![](http://41.media.tumblr.com/45c8d33bea2f92da707f4bbe66251d6b/tumblr_nuf7bgeyH51uz9e9oo1_1280.png)

シシマイ?
=========
Sisimai(シシマイ)はRFC5322準拠のエラーメールを解析し、解析結果をデータ構造に
変換するインターフェイスを提供するPerlモジュールです。
__シシマイ__はbounceHammer version 4として開発していたものであり、Version 4なので
__シ(Si)__から始まりマイ(MAI: __Mail Analyzing Interface__)を含む名前になりました。

主な特徴的機能
-----------------------------
* __エラーメールをデータ構造に変換__
  * Perlのデータ形式とJSONに対応
* __インストールも使用も簡単__
  * cpanm
  * git clone & make
* __高い解析精度__
  * 解析精度はbounceHammerの二倍
  * 27種類のMTAに対応
  * 21種類の著名なMSPに対応
  * 2種類の著名なメール配信クラウドに対応(JSON)
  * Feedback Loopにも対応
  * 27種類のエラー理由を検出
* __bounceHammer 2.7.13p3よりも高速に解析__
  * 1.7倍程高速


シシマイを使う準備
==================
動作環境
--------
Sisimaiの動作環境についての詳細は
[Sisimai | シシマイを使ってみる](http://libsisimai.org/ja/start)をご覧ください。

* [Perl 5.10.1 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)


インストール
------------
### CPANから

```shell
% sudo cpanm Sisimai
--> Working on Sisimai
Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.20.0.tar.gz ... OK
...
1 distribution installed
% perldoc -l Sisimai
/usr/local/lib/perl5/site_perl/5.20.0/Sisimai.pm
```

### GitHubから

```shell
% cd /usr/local/src
% git clone https://github.com/sisimai/p5-Sisimai.git
% cd ./p5-Sisimai
% sudo make install-from-local
--> Working on .
Configuring Sisimai-4.20.0 ... OK
1 distribution installed
```

使い方
======
基本的な使い方
--------------
下記のようにSisimaiの`make()`メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が配列リファレンスで返ってきます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $v = Sisimai->make('/path/to/mbox'); # or path to Maildir/

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

        my $h = $e->damn();             # Convert to HASH reference
        my $j = $e->dump('json');       # Convert to JSON string
        print $e->dump('json');         # JSON formatted bounce data
    }
}

# Get JSON string from parsed mailbox or Maildir/
my $j = Sisimai->dump('/path/to/mbox'); # or path to Maildir/
                                        # dump() is added in v4.1.27
print $j;                               # parsed data as JSON

# dump() method also accepts "delivered" option like the following code:
my $j = Sisimai->dump('/path/to/mbox', 'delivered' => 1);
```

バウンスオブジェクト(JSON)を読む
--------------------------------
メール配信クラウドからAPIで取得したバウンスオブジェクト(JSON)を読んで解析する
場合は、次のようなコードを書いてください。この機能はSisimai v4.20.0で実装され
ました。

```perl
#! /usr/bin/env perl
use JSON;
use Sisimai;

my $j = JSON->new;
my $q = '{"json":"string",...}'
my $v = Sisimai->make($j->decode($q), 'input' => 'json');

if( defined $v ) {
    for my $e ( @$v ) { ... }
}
```
現時点ではAmazon SESとSendgridのみをサポートしています。

コールバック機能
----------------
Sisimai 4.19.0から、`Sisimai->make()`と`Sisimai->dump()`にコードリファレンスを
引数`hook`に指定できるようになりました。`hook`に指定したサブルーチンによって処理
された結果は`Sisimai::Data->catch`メソッドで得ることができます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $callbackto = sub {
    my $emdata = shift;
    my $caught = { 'x-mailer' => '' };

    if( $emdata->{'message'} =~ m/^X-Mailer:\s*(.+)$/m ) {
        $caught->{'x-mailer'} = $1;
    }
    return $caught;
};
my $data = Sisimai->make('/path/to/mbox', 'hook' => $callbackto);
my $json = Sisimai->dump('/path/to/mbox', 'hook' => $callbackto);

print $data->[0]->catch->{'x-mailer'};    # Apple Mail (2.1283)
```

コールバック機能のより詳細な使い方は
[Sisimai | 解析方法 - コールバック機能](http://libsisimai.org/ja/usage/#callback)
をご覧ください。

ワンライナーで
--------------
Sisimai 4.1.27から登場した`dump()`メソッドを使うとワンライナーでJSON化した解析結果
が得られます。

```shell
% perl -MSisimai -lE 'print Sisimai->dump(shift)' /path/to/mbox
```

解析結果の例(JSON)
------------------
```json
[{"recipient": "kijitora@example.jp", "addresser": "shironeko@1jo.example.org", "feedbacktype": "", "action": "failed", "subject": "Nyaaaaan", "smtpcommand": "DATA", "diagnosticcode": "550 Unknown user kijitora@example.jp", "listid": "", "destination": "example.jp", "smtpagent": "Courier", "lhost": "1jo.example.org", "deliverystatus": "5.0.0", "timestamp": 1291954879, "messageid": "201012100421.oBA4LJFU042012@1jo.example.org", "diagnostictype": "SMTP", "timezoneoffset": "+0900", "reason": "filtered", "token": "ce999a4c869e3f5e4d8a77b2e310b23960fb32ab", "alias": "", "senderdomain": "1jo.example.org", "rhost": "mfsmax.example.jp"}, {"diagnostictype": "SMTP", "timezoneoffset": "+0900", "reason": "userunknown", "timestamp": 1381900535, "messageid": "E1C50F1B-1C83-4820-BC36-AC6FBFBE8568@example.org", "token": "9fe754876e9133aae5d20f0fd8dd7f05b4e9d9f0", "alias": "", "senderdomain": "example.org", "rhost": "mx.bouncehammer.jp", "action": "failed", "addresser": "kijitora@example.org", "recipient": "userunknown@bouncehammer.jp", "feedbacktype": "", "smtpcommand": "DATA", "subject": "バウンスメールのテスト(日本語)", "destination": "bouncehammer.jp", "listid": "", "diagnosticcode": "550 5.1.1 <userunknown@bouncehammer.jp>... User Unknown", "deliverystatus": "5.1.1", "lhost": "p0000-ipbfpfx00kyoto.kyoto.example.co.jp", "smtpagent": "Sendmail"}]
```

シシマイの仕様
==============
新旧の違い(bounceHammerとSisimai)
---------------------------------
bounceHammer version 2.7.13p3とSisimai(シシマイ)は下記のような違いがあります。
違いの詳細については[Sisimai | 違いの一覧](http://libsisimai.org/ja/diff)をご覧
ください。

| 機能                                           | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| 動作環境(Perl)                                 | 5.10 - 5.14   | 5.10 - 5.24 |
| コマンドラインツール                           | あり          | 無し        |
| 商用MTAとMSP対応解析モジュール                 | 無し          | あり(同梱)  |
| WebUIとAPI                                     | あり          | 無し        |
| 解析済バウンスデータを保存するDBスキーマ       | あり          | 無し[1]     |
| 解析精度の割合(2000通のメール)[2]              | 0.49          | 1.00        |
| メール解析速度(1000通のメール)                 | 4.24秒        | 2.33秒      |
| 検出可能なバウンス理由の数                     | 19            | 27          |
| 2件以上のバウンスがあるメールの解析            | 1件目だけ     | 全件解析可能|
| FeedBack Loop/ARF形式のメール解析              | 非対応        | 対応済      |
| 宛先ドメインによる分類項目                     | あり          | 無し        |
| 解析結果の出力形式                             | YAML,JSON,CSV | JSON        |
| インストール作業が簡単かどうか                 | やや面倒      | 簡単で楽    |
| cpanまたはcpanmコマンドでのインストール        | 非対応        | 対応済      |
| 依存モジュール数(Perlのコアモジュールを除く)   | 24モジュール  | 2モジュール |
| LOC:ソースコードの行数                         | 18200行       | 8800行      |
| テスト件数(t/,xt/ディレクトリ)                 | 27365件       | 187600件    |
| ライセンス                                     | GPLv2かPerl   | 二条項BSD   |
| 開発会社によるサポート契約                     | 終売(EOS)     | 提供中      |

1. DBIまたは好きなORMを使って自由に実装してください
2. [./ANALYTICAL-PRECISION](https://github.com/sisimai/p5-Sisimai/blob/master/ANALYTICAL-PRECISION)を参照


MTA/MSPモジュール一覧
---------------------
下記はSisimaiに含まれてるMTA/MSP(メールサービスプロバイダ)モジュールの一覧です。
より詳しい情報は[Sisimai | 解析エンジン](http://libsisimai.org/ja/engine)を
ご覧ください。

| Module Name(Sisimai::)   | Description                                       |
|--------------------------|---------------------------------------------------|
| MTA::Activehunter        | TransWARE Active!hunter                           |
| MTA::ApacheJames         | Java Apache Mail Enterprise Server(> v4.1.26)     |
| MTA::Courier             | Courier MTA                                       |
| MTA::Domino              | IBM Domino Server                                 |
| MTA::Exchange2003        | Microsoft Exchange Server 2003                    |
| MTA::Exchange2007        | Microsoft Exchange Server 2007 (> v4.18.0)        |
| MTA::Exim                | Exim                                              |
| MTA::IMailServer         | IPSWITCH IMail Server                             |
| MTA::InterScanMSS        | Trend Micro InterScan Messaging Security Suite    |
| MTA::MXLogic             | McAfee SaaS                                       |
| MTA::MailFoundry         | MailFoundry                                       |
| MTA::MailMarshalSMTP     | Trustwave Secure Email Gateway                    |
| MTA::McAfee              | McAfee Email Appliance                            |
| MTA::MessagingServer     | Oracle Communications Messaging Server            |
| MTA::mFILTER             | Digital Arts m-FILTER                             |
| MTA::Notes               | Lotus Notes                                       |
| MTA::OpenSMTPD           | OpenSMTPD                                         |
| MTA::Postfix             | Postfix                                           |
| MTA::qmail               | qmail                                             |
| MTA::Sendmail            | V8Sendmail: /usr/sbin/sendmail                    |
| MTA::SurfControl         | WebSense SurfControl                              |
| MTA::V5sendmail          | Sendmail version 5                                |
| MTA::X1                  | Unknown MTA #1                                    |
| MTA::X2                  | Unknown MTA #2                                    |
| MTA::X3                  | Unknown MTA #3                                    |
| MTA::X4                  | Unknown MTA #4 qmail clones(> v4.1.23)            |
| MTA::X5                  | Unknown MTA #5 (> v4.13.0 )                       |
| MSP::DE::EinsUndEins     | 1&1: http://www.1and1.de                          |
| MSP::DE::GMX             | GMX: http://www.gmx.net                           |
| MSP::JP::Biglobe         | BIGLOBE: http://www.biglobe.ne.jp                 |
| MSP::JP::EZweb           | au EZweb: http://www.au.kddi.com/mobile/          |
| MSP::JP::KDDI            | au by KDDI: http://www.au.kddi.com                |
| MSP::RU::MailRu          | @mail.ru: https://mail.ru                         |
| MSP::RU::Yandex          | Yandex.Mail: http://www.yandex.ru                 |
| MSP::UK::MessageLabs     | Symantec.cloud http://www.messagelabs.com         |
| MSP::US::AmazonSES       | AmazonSES(Sending): http://aws.amazon.com/ses/    |
| MSP::US::AmazonWorkMail  | Amazon WorkMail: https://aws.amazon.com/workmail/ |
| MSP::US::Aol             | Aol Mail: http://www.aol.com                      |
| MSP::US::Bigfoot         | Bigfoot: http://www.bigfoot.com                   |
| MSP::US::Facebook        | Facebook: https://www.facebook.com                |
| MSP::US::Google          | Google Gmail: https://mail.google.com             |
| MSP::US::Office365       | Microsoft Office 365: http://office.microsoft.com/|
| MSP::US::Outlook         | Microsoft Outlook.com: https://www.outlook.com/   |
| MSP::US::ReceivingSES    | AmazonSES(Receiving): http://aws.amazon.com/ses/  |
| MSP::US::SendGrid        | SendGrid: http://sendgrid.com/                    |
| MSP::US::Verizon         | Verizon Wireless: http://www.verizonwireless.com  |
| MSP::US::Yahoo           | Yahoo! MAIL: https://www.yahoo.com                |
| MSP::US::Zoho            | Zoho Mail: https://www.zoho.com                   |
| CED::US::AmazonSES       | AmazonSES(JSON): http://aws.amazon.com/ses/       |
| CED::US::SendGrid        | SendGrid(JSON): http://sendgrid.com/              |
| ARF                      | Abuse Feedback Reporting Format                   |
| RFC3464                  | Fallback Module for MTAs                          |
| RFC3834                  | Detector for auto replied message (> v4.1.28)     |

バウンス理由の一覧
------------------
Sisimaiは下記のエラー27種を検出します。バウンス理由についてのより詳細な情報は
[Sisimai | バウンス理由の一覧](http://libsisimai.org/ja/reason)をご覧ください。

| バウンス理由   | 理由の説明                                 | 実装バージョン |
|----------------|--------------------------------------------|----------------|
| Blocked        | IPアドレスやホスト名による拒否             |                |
| ContentError   | 不正な形式のヘッダまたはメール             |                |
| Delivered[1]   | 正常に配信された                           | v4.16.0        |
| ExceedLimit    | メールサイズの超過                         |                |
| Expired        | 配送時間切れ                               |                |
| Feedback       | 元メールへの苦情によるバウンス(FBL形式の)  |                |
| Filtered       | DATAコマンド以降で拒否された               |                |
| HasMoved       | 宛先メールアドレスは移動した               |                |
| HostUnknown    | 宛先ホスト名が存在しない                   |                |
| MailboxFull    | メールボックスが一杯                       |                |
| MailerError    | メールプログラムのエラー                   |                |
| MesgTooBig     | メールが大き過ぎる                         |                |
| NetworkError   | DNS等ネットワーク関係のエラー              |                |
| NotAccept      | 宛先ホストはメールを受けとらない           |                |
| OnHold         | エラー理由の特定は保留                     |                |
| Rejected       | エンベロープFromで拒否された               |                |
| NoRelaying     | リレーの拒否                               |                |
| SecurityError  | ウィルスの検出または認証失敗               |                |
| SpamDetected   | メールはスパムとして判定された             |                |
| Suspend        | 宛先アカウントは一時的に停止中             |                |
| SyntaxError    | SMTPの文法エラー                           | v4.17.0        |
| SystemError    | 宛先サーバでのOSレベルのエラー             |                |
| SystemFull     | 宛先サーバのディスクが一杯                 |                |
| TooManyConn    | 接続制限数を超過した                       |                |
| UserUnknown    | 宛先メールアドレスは存在しない             |                |
| Undefined      | バウンスした理由は特定出来ず               |                |
| Vacation       | 自動応答メッセージ                         | v4.1.28        |

1. このバウンス理由は標準では解析結果に含まれません

解析後のデータ構造
------------------
下記の表は解析後のバウンスメールの構造(`Sisimai::Data`)です。データ構造のより詳細な情報は
[Sisimai | Sisimai::Dataのデータ構造](http://libsisimai.org/ja/data)をご覧ください。

| アクセサ名     | 値の説明                                                    |
|----------------|-------------------------------------------------------------|
| action         | Action:ヘッダの値                                           |
| addresser      | 送信者のアドレス                                            |
| alias          | 受信者アドレスのエイリアス                                  |
| catch          | 引数に指定したフックメソッドが返すデータ
| destination    | "recipient"のドメイン部分                                   |
| deliverystatus | 配信状態(DSN)の値(例: 5.1.1, 4.4.7)                         |
| diagnosticcode | エラーメッセージ                                            |
| diagnostictype | エラーメッセージの種別                                      |
| feedbacktype   | Feedback-Typeのフィールド                                   |
| lhost          | 送信側MTAのホスト名                                         |
| listid         | 本メールのList-Idヘッダの値                                 |
| messageid      | 元メールのMessage-Idヘッダの値                              |
| reason         | 検出したバウンスした理由                                    |
| recipient      | バウンスした受信者のアドレス                                |
| replycode      | SMTP応答コード(例: 550, 421)                                |
| rhost          | 受信側MTAのホスト名                                         |
| senderdomain   | "addresser"のドメイン部分                                   |
| softbounce     | ソフトバウンスであるかどうか(0=hard,1=soft,-1=不明)         |
| smtpagent      | 解析に使用したMTA/MSPのモジュール名(Sisimai::MTA::,MSP::)   |
| smtpcommand    | セッション中最後のSMTPコマンド                              |
| subject        | 元メールのSubjectヘッダの値(UTF-8)                          |
| timestamp      | バウンスした日時(UNIXマシンタイム)                          |
| timezoneoffset | タイムゾーンの時差(例:+0900)                                |
| token          | 送信者と受信者・時刻から作られるハッシュ値                  |

解析出来ないメール
------------------
解析出来ないバウンスメールは`set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet`
ディレクトリにはいっています。もしもSisimaiで解析出来ないメールを見つけたら、
このディレクトリに追加してPull-Requestを送ってください。


その他の情報
============
関連サイト
----------
* __@libsisimai__ | [Sisimai on Twitter (@libsisimai)](https://twitter.com/libsisimai)
* __libSISIMAI.ORG__ | [Sisimai | The Successor To bounceHammer, Library to parse bounce mails](http://libsisimai.org/)
* __GitHub__ | [github.com/sisimai/p5-Sisimai](https://github.com/sisimai/p5-Sisimai)
* __CPAN__ | [Sisimai - Mail Analyzing Interface for bounce mails. - metacpan.org](https://metacpan.org/pod/Sisimai)
* __CPAN Testers Reports__ | [CPAN Testers Reports: Reports for Sisimai](http://cpantesters.org/distro/S/Sisimai.html)
* __Ruby verson__ | [Ruby version of Sisimai](https://github.com/sisimai/rb-Sisimai)
* __bounceHammer.JP__ | [bounceHammer will be EOL on February 29, 2016](http://bouncehammer.jp/)

参考情報
--------
* [README.md - README.md in English](https://github.com/sisimai/p5-Sisimai/blob/master/README.md)
* [RFC3463 - Enhanced Mail System Status Codes](https://tools.ietf.org/html/rfc3463)
* [RFC3464 - An Extensible Message Format for Delivery Status Notifications](https://tools.ietf.org/html/rfc3464)
* [RFC3834 - Recommendations for Automatic Responses to Electronic Mail](https://tools.ietf.org/html/rfc3834)
* [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC5322 - Internet Message Format](https://tools.ietf.org/html/rfc5322)

作者
----
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

著作権
------
Copyright (C) 2014-2016 azumakuniyuki, All Rights Reserved.

ライセンス
----------
This software is distributed under The BSD 2-Clause License.

