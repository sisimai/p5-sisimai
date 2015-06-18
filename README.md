[![Build Status](https://travis-ci.org/azumakuniyuki/p5-Sisimai.svg?branch=master)](https://travis-ci.org/azumakuniyuki/p5-Sisimai) 
[![Coverage Status](https://img.shields.io/coveralls/azumakuniyuki/p5-Sisimai.svg)](https://coveralls.io/r/azumakuniyuki/p5-Sisimai)

         ____  _     _                 _ 
        / ___|(_)___(_)_ __ ___   __ _(_)
        \___ \| / __| | '_ ` _ \ / _` | |
         ___) | \__ \ | | | | | | (_| | |
        |____/|_|___/_|_| |_| |_|\__,_|_|
                                 

What is Sisimai ? | シシマイ?
=============================

Sisimai is the system formerly known as bounceHammer 4, is a Perl module for 
analyzing bounce emails and output parsed results as a JSON format. "Sisimai"
is a coined word: Sisi (the number 4 is pronounced "Si" in Japanese) and MAI
(acronym of "Mail Analyzing Interface").

"シシマイ"はbounceHammer version 4として開発していたエラーメール解析モジュール
で、解析結果をJSONで出力します。Version 4なので"シ"から始まりマイ(MAI: Mail 
Analyzing Interface)を含む名前になりました。

System requirements | 動作環境
------------------------------

* [Perl 5.10.1 or later](http://www.perl.org/)

Dependencies | 依存モジュール
-----------------------------
Sisimai relies on:

* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)

Sisimaiは上記のモジュールに依存しています。

Install | インストール
----------------------

    % sudo cpanm Sisimai
    --> Working on Sisimai
    Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.1.20.tar.gz ... OK
    ...
    1 distribution installed
    % perldoc -l Sisimai
    /usr/local/lib/perl5/site_perl/5.20.0/Sisimai.pm

OR
    
    % cd /usr/local/src
    % git clone https://github.com/azumakuniyuki/p5-Sisimai.git
    % cd ./Sisimai
    % sudo cpanm .
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
my $v = Sisimai->make( '/path/to/mbox' );   # or Path to Maildir

if( defined $v ) {
    for my $e ( @$v ) {
        print ref $e;                   # Sisimai::Data
        print ref $e->recipient;        # Sisimai::Address
        print ref $e->timestamp;        # Sisimai::Time

        print $e->addresser->address;   # shironeko@example.org # From
        print $e->recipient->address;   # kijitora@example.jp   # To
        print $e->recipient->host;      # example.jp
        print $e->deliverystatus;       # 5.1.1
        print $e->reason;               # userunknown

        my $h = $e->damn();             # Convert to HASH reference
        my $j = $e->dump('json');       # Convert to JSON string
        print $e->dump('json');         # JSON formatted bounce data
    }

    # OR
    use JSON '-convert_blessed_universally';
    my $json = JSON->new->allow_blessed->convert_blessed;

    printf "%s\n", $json->encode( $v );
}
```

上記のようにSisimaiのmake()メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が配列リファレンスで返ってきます。


Differences between ver.2 and ver.4 | 新旧の違い
------------------------------------------------
The followings are the differences between version 2 (bounceHammer 2.7.13) and
version 4 (Sisimai).

| Features                                       | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| Command line tools                             | OK            | N/A         |
| Modules for Commercial MTAs                    | N/A           | Included    |
| WebUI/API                                      | OK            | N/A         |
| Database schema for storing parsed bounce data | Available     | N/A(1)      |
| Analysis accuracy ratio(2)                     | 0.64          | 1.00        |
| Parse 2 or more bounces in a single email      | Only 1st rcpt | ALL         |
| Parse FeedBack Loop Message/ARF format mail    | N/A           | OK          |
| Classification based on recipient domain       | Available     | N/A         |
| Output format of parsed data                   | YAML,JSON,CSV | JSON only(3)|
| The speed of parsing email(1484 files)         | 6.15s         | 3.16s       |
| Easy to install                                | No            | Yes         |
| Install using cpan or cpanm command            | N/A           | OK          |
| Dependencies                                   | 24 modules    | 2 modules   |
| LOC:Source lines of code                       | 18200 lines   | 7500 lines  |
| The number of tests in t/ directory            | 27365 tests   | 70500 tests |
| License                                        | GPLv2 or Perl | 2 clause BSD|
| Support Contract provided by Developer         | Available     | Coming soon |

1. Implement yourself with using DBI or any O/R Mapper you like
2. See ./ANALYSIS-ACCURACY
3. YAML format is available if "YAML" module has been installed

公開中のbouncehammer version 2.7.13とversion 4(シシマイ)は下記のような違いがあります。

| 機能                                           | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| コマンドラインツール                           | あり          | 無し        |
| 商用MTA対応解析モジュール                      | 無し          | あり(標準)  |
| WebUIとAPI                                     | あり          | 無し        |
| 解析済バウンスデータを保存するDBスキーマ       | あり          | 無し(1)     |
| 解析精度の割合(2)                              | 0.64          | 1.00        |
| 2件以上のバウンスがあるメールの解析            | 1件目だけ     | 全件対応    |
| FeedBack Loop/ARF形式のメール解析              | 非対応        | 対応済      |
| 宛先ドメインによる分類項目                     | あり          | 無し        |
| 解析結果の出力形式                             | YAML,JSON,CSV | JSONのみ(3) |
| メール解析の速度(1484通)                       | 6.15秒        | 3.16秒      |
| インストール作業が簡単かどうか                 | やや面倒      | 簡単で楽    |
| cpanまたはcpanmコマンドでのインストール        | 非対応        | 対応済      |
| 依存モジュール数                               | 24モジュール  | 2モジュール |
| LOC:ソースコードの行数                         | 18200行       | 7500行      |
| テスト件数(t/ディレクトリ)                     | 27365件       | 70500件     |
| ライセンス                                     | GPLv2かPerl   | 二条項BSD   |
| 開発会社によるサポート契約                     | 提供中        | 準備中      |

1. DBIまたは好きなORMを使って自由に実装してください
2. ./ANALYSIS-ACCURACY を参照
3. "YAML"モジュールが入っていればYAMLでの出力も可能

MTA/MSP Modules | MTA/MSPモジュール一覧
---------------------------------------
The following table is the list of MTA/MSP:(Mail Service Provider) modules.

| Module Name(Sisimai::)   | Description                                       |
|--------------------------|---------------------------------------------------|
| MTA::Activehunter        | TransWARE Active!hunter                           |
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
| MTA::Notes               | Lotus Notes                                       |
| MTA::OpenSMTPD           | OpenSMTPD                                         |
| MTA::Postfix             | Postfix                                           |
| MTA::Sendmail            | V8Sendmail: /usr/sbin/sendmail                    |
| MTA::SurfControl         | WebSense SurfControl                              |
| MTA::V5sendmail          | Sendmail version 5                                |
| MTA::X1                  | Unknown MTA #1                                    |
| MTA::X2                  | Unknown MTA #2                                    |
| MTA::X3                  | Unknown MTA #3                                    |
| MTA::X4                  | Unknown MTA #4 qmail clones                       |
| MTA::mFILTER             | Digital Arts m-FILTER                             |
| MTA::qmail               | qmail                                             |
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

上記はSisimaiに含まれてるMTA/MSP(メールサービスプロバイダ)モジュールの一覧です。

Bounce Reason List | バウンス理由の一覧
----------------------------------------
Sisimai can detect the following 22 bounce reasons.

| Reason(理由)   | Description                            | 理由の説明                       |
|----------------|----------------------------------------|----------------------------------|
| Blocked        | Blocked due to client IP address       | IPアドレスによる拒否             |
| ContentError   | Invalid format email                   | 不正な形式のメール               |
| ExceedLimit    | Message size exceeded the limit(5.2.3) | メールサイズの超過               |
| Expired        | Delivery time expired                  | 配送時間切れ                     |
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
| RelayingDenied | Relay access denied                    | リレーの拒否                     |
| SecurityError  | Virus detected or authentication error | ウィルスの検出または認証失敗     |
| Suspend        | Recipient's account is suspended       | 宛先アカウントは一時的に停止中   |
| SystemError    | Some error on the destination host     | 宛先サーバでのOSレベルのエラー   |
| SystemFull     | Disk full on the destination host      | 宛先サーバのディスクが一杯       |
| UserUnknown    | Recipient's address does not exist     | 宛先メールアドレスは存在しない   |
| Undefined      | Could not decide the error reason      | バウンスした理由は特定出来ず     |

Sisimaiは上記のエラー22種を検出します。

REPOSITORY | リポジトリ
-----------------------
[github.com/azumakuniyuki/p5-Sisimai](https://github.com/azumakuniyuki/p5-Sisimai)

WEB SITE | サイト
-----------------
[bounceHammer | an open source software for handling email bounces](http://bouncehammer.jp/)

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

