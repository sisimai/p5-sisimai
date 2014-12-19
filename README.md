[![Build Status](https://travis-ci.org/azumakuniyuki/Sisimai.svg?branch=master)](https://travis-ci.org/azumakuniyuki/Sisimai) 
[![Coverage Status](https://img.shields.io/coveralls/azumakuniyuki/Sisimai.svg)](https://coveralls.io/r/azumakuniyuki/Sisimai)

         ____  _     _                 _ 
        / ___|(_)___(_)_ __ ___   __ _(_)
        \___ \| / __| | '_ ` _ \ / _` | |
         ___) | \__ \ | | | | | | (_| | |
        |____/|_|___/_|_| |_| |_|\__,_|_|
                                 

What is Sisimai ? | シシマイ?
=============================

Sisimai is a core module of bounceHammer version. 4, is a Perl module for 
analyzing email bounce. "Sisimai" is a coined word: Sisi (the number 4 is 
pronounced "Si" in Japanese) and MAI (acronym of "Mail Analyzing Interface").

"シシマイ"はbounceHammer version 4の中核となるエラーメール解析モジュールです。
Version 4なので"シ"から始まりマイ(MAI: Mail Analyzing Interface)を含む名前になりました。

Differences between ver.2 and ver.4 | 新旧の違い
------------------------------------------------
The followings are the differences between version 2 (bounceHammer 2.7.13) and
version 4 (Sisimai).

| Features                                       | ver 2.7.13    | Sisimai      |
|------------------------------------------------|---------------|--------------|
| Command line tools                             | OK            | N/A          |
| Modules for Commercial MTAs                    | N/A(1)        | Included     |
| WebUI/API                                      | OK            | N/A          |
| Database schema for storing parsed bounce data | Available     | N/A(2)       |
| Analysis accuracy ratio(3)                     | 0.80          | 1.00         |
| Parse 2 or more bounces in a single email      | Only 1st rcpt | ALL          |
| Parse FeedBack Loop Message/ARF format mail    | N/A           | OK           |
| Classification based on recipient domain       | Available     | N/A          |
| Output format of parsed data                   | YAML,JSON,CSV | JSON only(4) |
| The speed of parsing email(750 files)          | 5.36s         | 2.95s        |
| Easy to install                                | No            | Yes          |
| Install using cpan or cpanm command            | N/A           | OK           |
| Dependencies                                   | 24 modules    | 3 modules    |
| License                                        | GPLv2 or Perl | 2 clause BSD |
| Support Contract provided by Developer         | Available     | Coming soon  |

1. bounceHammer-nails
2. Implement yourself with using DBI or any O/R Mapper you like
3. See ./ANALYSIS-ACCURACY
4. YAML format is available if "YAML" module has been installed

公開中のbouncehammer version 2.7.13とversion 4(シシマイ)は上記のような違いがあります。

| 機能                                           | ver 2.7.13    | Sisimai      |
|------------------------------------------------|---------------|--------------|
| コマンドラインツール                           | あり          | 無し         |
| 商用MTA対応解析モジュール                      | 無し(商用版,1)| あり(標準)   |
| WebUIとAPI                                     | あり          | 無し         |
| 解析済バウンスデータを保存するDBスキーマ       | あり          | 無し(2)      |
| 解析精度の割合(3)                              | 0.80          | 1.00         |
| 2件以上のバウンスがあるメールの解析            | 1件目だけ     | 全件対応     |
| FeedBack Loop/ARF形式のメール解析              | 非対応        | 対応済       |
| 宛先ドメインによる分類項目                     | あり          | 無し         |
| 解析結果の出力形式                             | YAML,JSON,CSV | JSONのみ(4)  |
| メール解析の速度(750通)                        | 5.36秒        | 2.95秒       |
| インストール作業が簡単かどうか                 | やや面倒      | 簡単で楽     |
| cpanまたはcpanmコマンドでのインストール        | 非対応        | 対応済       |
| 依存モジュール数                               | 24モジュール  | 3モジュール  |
| ライセンス                                     | GPLv2かPerl   | 二条項BSD    |
| 開発会社によるサポート契約                     | 提供中        | 準備中       |

1. bounceHammer-nails
2. DBIまたは好きなORMを使って自由に実装してください
3. ./ANALYSIS-ACCURACY を参照
4. "YAML"モジュールが入っていればYAMLでの出力も可能

System requirements | 動作環境
------------------------------

* [Perl 5.10.1 or later](http://www.perl.org/)

Dependencies | 依存モジュール
-----------------------------
Sisimai relies on:

* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)
* [__Try::Tiny__](https://metacpan.org/pod/Try::Tiny)

Sisimaiは上記のモジュールに依存しています。

Install | インストール
----------------------

    % sudo cpanm Sisimai
    --> Working on Sisimai
    Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.1.2.tar.gz ... OK
    ...
    1 distribution installed
    % perldoc -l Sisimai
    /usr/local/lib/perl5/site_perl/5.14.2/Sisimai.pm

OR
    
    % cd /usr/local/src
    % git clone https://github.com/azumakuniyuki/Sisimai.git
    % cd ./Sisimai
    % sudo cpanm .
    --> Working on .
    Configuring Sisimai-4.1.2 ... OK
    1 distribution installed


Basic usage | 基本的な使い方
----------------------------
make() method provides feature for getting parsed data from bounced email 
messages like following.

```perl
use Sisimai;
my $v = Sisimai->make( '/path/to/mbox' );   # or Path to Maildir

if( defined $v ) {
    for my $e ( @$v ) {
        print ref $e;                   # Sisimai::Data
        print $e->recipient->address;   # kijitora@example.jp
        print $e->reason;               # userunknown

        my $h = $e->damn();             # Convert to HASH reference
        my $j = $e->dump('json');       # Convert to JSON string
        print $e->dump('json');         # JSON formatted bounce data
    }
}
```

上記のようにSisimaiのmake()メソッドをmboxかMaildirのPATHを引数にして実行すると
解析結果が配列リファレンスで返ってきます。

REPOSITORY | リポジトリ
-----------------------
[github.com/azumakuniyuki/Sisimai](https://github.com/azumakuniyuki/Sisimai)

WEB SITE | サイト
-----------------
[bounceHammer | an open source software for handling email bounces](http://bouncehammer.jp/)

AUTHOR | 作者
-------------
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

COPYRIGHT | 著作権
------------------
Copyright (C) 2014 azumakuniyuki <perl.org@azumakuniyuki.org>,
All Rights Reserved.

LICENSE | ライセンス
--------------------
This software is distributed under The BSD 2-Clause License.

