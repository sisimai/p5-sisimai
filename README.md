[![Build Status](https://travis-ci.org/azumakuniyuki/p5-Sisimai.svg?branch=master)](https://travis-ci.org/azumakuniyuki/p5-Sisimai) 
[![Coverage Status](https://img.shields.io/coveralls/azumakuniyuki/p5-Sisimai.svg)](https://coveralls.io/r/azumakuniyuki/p5-Sisimai)

![](http://41.media.tumblr.com/45c8d33bea2f92da707f4bbe66251d6b/tumblr_nuf7bgeyH51uz9e9oo1_1280.png)

What is Sisimai ? | シシマイ?
=============================
Sisimai is a Perl module for analyzing RFC5322 bounce emails and generating
structured data from parsed results. Sisimai is the system formerly known as
bounceHammer 4. "Sisimai" is a coined word: Sisi (the number 4 is pronounced
"Si" in Japanese) and MAI (acronym of "Mail Analyzing Interface").

Sisimai(シシマイ)はRFC5322準拠のエラーメールを解析し、解析結果をデータ構造に
変換するインターフェイスを提供するPerlモジュールです。
"シシマイ"はbounceHammer version 4として開発していたものであり、Version 4なので
"シ"から始まりマイ(MAI: Mail Analyzing Interface)を含む名前になりました。

Features | 主な機能
-------------------
* __Convert bounce mails to structured data__ | __エラーメールをデータ構造に変換__
  * Supported format are Perl, JSON | Perlのデータ形式とJSONに対応
* __Easy to install, use.__ | __インストールも使用も簡単__
  * cpanm
  * git clone
* __High analytical precision__ | __高い解析精度__
  * Support 21 known MTAs and 4 unknown MTAs | 25種類のMTAに対応
  * Support 18 major MSPs(Mail Service Providers) | 18種類の著名なMSPに対応
  * Support Feedback Loop Message(ARF) | Feedback Loopにも対応
  * Can detect 25 error reasons | 25種類のエラー理由を検出
* __Faster than bounceHammer version 2.7.X__ | __bounceHammer 2.7.Xよりも高速に解析__


System requirements | 動作環境
------------------------------
More details about system requirements are available at available at 
[Sisimai — How to Install and Start](http://libsisimai.org/start) page.

* [Perl 5.10.1 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)


Install | インストール
----------------------

### From CPAN

    % sudo cpanm Sisimai
    --> Working on Sisimai
    Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.1.20.tar.gz ... OK
    ...
    1 distribution installed
    % perldoc -l Sisimai
    /usr/local/lib/perl5/site_perl/5.20.0/Sisimai.pm

### From GitHub

    % cd /usr/local/src
    % git clone https://github.com/azumakuniyuki/p5-Sisimai.git
    % cd ./p5-Sisimai
    % sudo make install-from-local
    --> Working on .
    Configuring Sisimai-4.1.20 ... OK
    1 distribution installed


Basic usage | 基本的な使い方
----------------------------
make() method provides feature for getting parsed data from bounced email 
messages like following.

```perl
#! /usr/bin/env perl
use Sisimai;
my $v = Sisimai->make('/path/to/mbox'); # or path to Maildir/

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

```

```json
[{"recipient": "kijitora@example.jp", "addresser": "shironeko@1jo.example.org", "feedbacktype": "", "action": "failed", "subject": "Nyaaaaan", "smtpcommand": "DATA", "diagnosticcode": "550 Unknown user kijitora@example.jp", "listid": "", "destination": "example.jp", "smtpagent": "Courier", "lhost": "1jo.example.org", "deliverystatus": "5.0.0", "timestamp": 1291954879, "messageid": "201012100421.oBA4LJFU042012@1jo.example.org", "diagnostictype": "SMTP", "timezoneoffset": "+0900", "reason": "filtered", "token": "ce999a4c869e3f5e4d8a77b2e310b23960fb32ab", "alias": "", "senderdomain": "1jo.example.org", "rhost": "mfsmax.example.jp"}, {"diagnostictype": "SMTP", "timezoneoffset": "+0900", "reason": "userunknown", "timestamp": 1381900535, "messageid": "E1C50F1B-1C83-4820-BC36-AC6FBFBE8568@example.org", "token": "9fe754876e9133aae5d20f0fd8dd7f05b4e9d9f0", "alias": "", "senderdomain": "example.org", "rhost": "mx.bouncehammer.jp", "action": "failed", "addresser": "kijitora@example.org", "recipient": "userunknown@bouncehammer.jp", "feedbacktype": "", "smtpcommand": "DATA", "subject": "バウンスメールのテスト(日本語)", "destination": "bouncehammer.jp", "listid": "", "diagnosticcode": "550 5.1.1 <userunknown@bouncehammer.jp>... User Unknown", "deliverystatus": "5.1.1", "lhost": "p0000-ipbfpfx00kyoto.kyoto.example.co.jp", "smtpagent": "Sendmail"}]
```

上記のようにSisimaiのmake()メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が配列リファレンスで返ってきます。

One-Liner | ワンライナーで
--------------------------

Beginning with Sisimai 4.1.27, dump() method is available and you can get parsed
data as JSON using the method.

```
% perl -MSisimai -lE 'print Sisimai->dump(shift)' /path/to/mbox
```

Sisimai 4.1.27から登場したdump()メソッドを使うとワンライナーでJSON化した解析結果
が得られます。


Differences between ver.2 and Sisimai | 新旧の違い
--------------------------------------------------
The followings are the differences between version 2 (bounceHammer 2.7.13) and
Sisimai.

| Features                                       | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| System requirements(Perl)                      | 5.10 - 5.14   | 5.10 - 5.22 |
| Command line tools                             | Available     | N/A         |
| Modules for Commercial MTAs and MPSs           | N/A           | Included    |
| WebUI/API                                      | Included      | N/A         |
| Database schema for storing parsed bounce data | Available     | N/A(1)      |
| Analytical precision ratio(1915 files) (2)     | 0.50          | 1.00        |
| The speed of parsing email(1915 files)         | 5.79s         | 5.13s       |
| Parse 2 or more bounces in a single email      | Only 1st rcpt | ALL         |
| Parse FeedBack Loop Message/ARF format mail    | N/A           | OK          |
| Classification based on recipient domain       | Available     | N/A         |
| Output format of parsed data                   | YAML,JSON,CSV | JSON only   |
| Easy to install                                | No            | Yes         |
| Install using cpan or cpanm command            | N/A           | OK          |
| Dependencies (Except core modules of Perl)     | 24 modules    | 2 modules   |
| LOC:Source lines of code                       | 18200 lines   | 7800 lines  |
| The number of tests in t/ directory            | 27365 tests   | 147200 tests|
| License                                        | GPLv2 or Perl | 2 clause BSD|
| Support Contract provided by Developer         | Available     | Coming soon |

1. Implement yourself with using DBI or any O/R Mapper you like
2. See ./ANALYTICAL-PRECISION

公開中のbouncehammer version 2.7.13とSisimai(シシマイ)は下記のような違いがあります。

| 機能                                           | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| 動作環境(Perl)                                 | 5.10 - 5.14   | 5.10 - 5.22 |
| コマンドラインツール                           | あり          | 無し        |
| 商用MTAとMSP対応解析モジュール                 | 無し          | あり(標準)  |
| WebUIとAPI                                     | あり          | 無し        |
| 解析済バウンスデータを保存するDBスキーマ       | あり          | 無し(1)     |
| 解析精度の割合(1915通)(2)                      | 0.50          | 1.00        |
| メール解析の速度(1915通)                       | 5.79秒        | 5.13秒      |
| 2件以上のバウンスがあるメールの解析            | 1件目だけ     | 全件対応    |
| FeedBack Loop/ARF形式のメール解析              | 非対応        | 対応済      |
| 宛先ドメインによる分類項目                     | あり          | 無し        |
| 解析結果の出力形式                             | YAML,JSON,CSV | JSONのみ    |
| インストール作業が簡単かどうか                 | やや面倒      | 簡単で楽    |
| cpanまたはcpanmコマンドでのインストール        | 非対応        | 対応済      |
| 依存モジュール数(Perlのコアモジュールを除く)   | 24モジュール  | 2モジュール |
| LOC:ソースコードの行数                         | 18200行       | 7800行      |
| テスト件数(t/ディレクトリ)                     | 27365件       | 147200件    |
| ライセンス                                     | GPLv2かPerl   | 二条項BSD   |
| 開発会社によるサポート契約                     | 提供中        | 準備中      |

1. DBIまたは好きなORMを使って自由に実装してください
2. ./ANALYTICAL-PRECISIONを参照


MTA/MSP Modules | MTA/MSPモジュール一覧
---------------------------------------
The following table is the list of MTA/MSP:(Mail Service Provider) modules.

| Module Name(Sisimai::)   | Description                                       |
|--------------------------|---------------------------------------------------|
| MTA::Activehunter        | TransWARE Active!hunter                           |
| MTA::ApacheJames         | Java Apache Mail Enterprise Server(> v4.1.26)     |
| MTA::Courier             | Courier MTA                                       |
| MTA::Domino              | IBM Domino Server                                 |
| MTA::Exchange            | Microsoft Exchange Server                         |
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
| MSP::DE::EinsUndEins     | 1&1: http://www.1and1.de                          |
| MSP::DE::GMX             | GMX: http://www.gmx.net                           |
| MSP::JP::Biglobe         | BIGLOBE: http://www.biglobe.ne.jp                 |
| MSP::JP::EZweb           | au EZweb: http://www.au.kddi.com/mobile/          |
| MSP::JP::KDDI            | au by KDDI: http://www.au.kddi.com                |
| MSP::RU::MailRu          | @mail.ru: https://mail.ru                         |
| MSP::RU::Yandex          | Yandex.Mail: http://www.yandex.ru                 |
| MSP::UK::MessageLabs     | Symantec.cloud http://www.messagelabs.com         |
| MSP::US::AmazonSES       | AmazonSES: http://aws.amazon.com/ses/             |
| MSP::US::Aol             | Aol Mail: http://www.aol.com                      |
| MSP::US::Bigfoot         | Bigfoot: http://www.bigfoot.com                   |
| MSP::US::Facebook        | Facebook: https://www.facebook.com                |
| MSP::US::Google          | Google Gmail: https://mail.google.com             |
| MSP::US::Outlook         | Microsoft Outlook.com: https://www.outlook.com/   |
| MSP::US::SendGrid        | SendGrid: http://sendgrid.com/                    |
| MSP::US::Verizon         | Verizon Wireless: http://www.verizonwireless.com  |
| MSP::US::Yahoo           | Yahoo! MAIL: https://www.yahoo.com                |
| MSP::US::Zoho            | Zoho Mail: https://www.zoho.com                   |
| ARF                      | Abuse Feedback Reporting Format                   |
| RFC3464                  | Fallback Module for MTAs                          |
| RFC3834                  | Detector for auto replied message (> v4.1.28)     |

上記はSisimaiに含まれてるMTA/MSP(メールサービスプロバイダ)モジュールの一覧です。


Bounce Reason List | バウンス理由の一覧
----------------------------------------
Sisimai can detect the following 25 bounce reasons. More details about reasons
are available at [Sisimai — Bounce Reason List Sisimai detects](http://libsisimai.org/reason)
page.

| Reason(理由)   | Description                            | 理由の説明                       |
|----------------|----------------------------------------|----------------------------------|
| Blocked        | Blocked due to client IP address       | IPアドレスによる拒否             |
| ContentError   | Invalid format email                   | 不正な形式のメール               |
| ExceedLimit    | Message size exceeded the limit(5.2.3) | メールサイズの超過               |
| Expired        | Delivery time expired                  | 配送時間切れ                     |
| Feedback       | Bounced for a complaint of the message | 元メールへの苦情によるバウンス   |
| Filtered       | Rejected after DATA command            | DATAコマンド以降で拒否された     |
| HasMoved       | Destination mail addrees has moved     | 宛先メールアドレスは移動した     |
| HostUnknown    | Unknown destination host name          | 宛先ホスト名が存在しない         |
| MailboxFull    | Recipient's mailbox is full            | メールボックスが一杯             |
| MailerError    | Mailer program error                   | メールプログラムのエラー         |
| MesgTooBig     | Message size is too big(5.3.4)         | メールが大き過ぎる               |
| NetworkError   | Network error: DNS or routing          | DNS等ネットワーク関係のエラー    |
| SpamDetected   | Detected a message as spam             | メールはスパムとして判定された   |
| NotAccept      | Destinaion does not accept any message | 宛先ホストはメールを受けとらない |
| OnHold         | Deciding the bounce reason is on hold  | エラー理由の特定は保留           |
| Rejected       | Rejected due to envelope from address  | エンベロープFromで拒否された     |
| NoRelaying     | Relay access denied                    | リレーの拒否                     |
| SecurityError  | Virus detected or authentication error | ウィルスの検出または認証失敗     |
| Suspend        | Recipient's account is suspended       | 宛先アカウントは一時的に停止中   |
| SystemError    | Some error on the destination host     | 宛先サーバでのOSレベルのエラー   |
| SystemFull     | Disk full on the destination host      | 宛先サーバのディスクが一杯       |
| TooManyConn    | Connection rate limit exceeded         | 接続制限数を超過した             |
| UserUnknown    | Recipient's address does not exist     | 宛先メールアドレスは存在しない   |
| Vacation       | Auto replied message such as vacation  | 自動応答メッセージ(vacationなど) |
|                | (implemented at v4.1.28)               | (v4.1.28から実装)                |
| Undefined      | Could not decide the error reason      | バウンスした理由は特定出来ず     |

Sisimaiは上記のエラー25種を検出します。


Parsed data structure | 解析後のデータ構造
------------------------------------------
The following table shows a data structure(Sisimai::Data) of parsed bounce mail.
More details about data structure are available at available at 
[Sisimai — Data Structure of Sisimai::Data Object](http://libsisimai.org/data) page.

| Name           | Description                           | 値の説明                       |
|----------------|---------------------------------------|--------------------------------|
| action         | The value of Action: header           | Action:ヘッダの値              |
| addresser      | The From address                      | 送信者のアドレス               |
| alias          | Alias of the recipient                | 受信者アドレスのエイリアス     |
| destination    | The domain part of the "recipinet"    | "recipient"のドメイン部分      |
| deliverystatus | Delivery Status(DSN)                  | 配信状態(DSN)の値              |
| diagnosticcode | Error message                         | エラーメッセージ               |
| diagnostictype | Error message type                    | エラーメッセージの種別         |
| feedbacktype   | Feedback Type                         | Feedback-Typeのフィールド      |
| lhost          | local host name(local MTA)            | 送信側MTAのホスト名            |
| listid         | List-Id: header of each ML            | List-Idヘッダの値              |
| messageid      | Message-Id: of the original message   | 元メールのMessage-Id           |
| reason         | Detected bounce reason                | 検出したバウンスした理由       |
| recipient      | Recipient address which bounced       | バウンスした受信者のアドレス   |
| replycode      | SMTP Reply Code                       | SMTP応答コード                 |
| rhost          | Remote host name(remote MTA)          | 受信側MTAのホスト名            |
| senderdomain   | The domain part of the "addresser"    | "addresser"のドメイン部分      |
| softbounce     | The bounce is soft bounce or not      | ソフトバウンスであるかどうか   |
| smtpagent      | MTA name(Sisimai::MTA::, MSP::)       | MTA名(Sisimai::MTA::,MSP::)    |
| smtpcommand    | The last SMTP command in the session  | セッション中最後のSMTPコマンド |
| subject        | Subject of the original message(UTF8) | 元メールのSubject(UTF-8)       |
| timestamp      | Date: header in the original message  | 元メールのDate                 |
| timezoneoffset | Time zone offset(seconds)             | タイムゾーンの時差             |
| token          | MD5 value of addresser and recipient  | 送信者と受信者のハッシュ値     |

上記の表は解析後のバウンスメールの構造(Sisimai::Data)です。


Emails could not be parsed | 解析出来ないメール
-----------------------------------------------
Bounce mails which could not be parsed is in eg/cannot-parse-yet directory. 
If you find any bounce email cannot be parsed using Sisimai, please add the
email into the directory and send Pull-Request to this repository.

解析出来ないメールはeg/cannot-parse-yetディレクトリにはいっています。もしも
Sisimaiで解析出来ないメールを見つけたら、このディレクトリに追加してPull-Request
を送ってください。


REPOSITORY | リポジトリ
-----------------------
[github.com/azumakuniyuki/p5-Sisimai](https://github.com/azumakuniyuki/p5-Sisimai)


SEE ALSO | 参考サイト
---------------------
* [RFC3463 - Enhanced Mail System Status Codes](https://tools.ietf.org/html/rfc3463)
* [RFC3464 - An Extensible Message Format for Delivery Status Notifications](https://tools.ietf.org/html/rfc3464)
* [RFC3834 - Recommendations for Automatic Responses to Electronic Mail](https://tools.ietf.org/html/rfc3834)
* [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC5322 - Internet Message Format](https://tools.ietf.org/html/rfc5322)


WEB SITE | サイト
-----------------
[Sisimai — A successor to bounceHammer, Library to parse error mails(http://libsisimai.org/)](http://libsisimai.org/)


AUTHOR | 作者
-------------
[@azumakuniyuki](https://twitter.com/azumakuniyuki)


COPYRIGHT | 著作権
------------------
Copyright (C) 2014-2015 azumakuniyuki <perl.org@azumakuniyuki.org>,
All Rights Reserved.


LICENSE | ライセンス
--------------------
This software is distributed under The BSD 2-Clause License.

