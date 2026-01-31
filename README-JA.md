![](https://libsisimai.org/static/images/logo/sisimai-x01.png)
[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/sisimai/p5-sisimai/blob/master/LICENSE)
[![Perl](https://img.shields.io/badge/perl-v5.26--v5.42-blue.svg)](https://www.perl.org)
[![CPAN](https://img.shields.io/badge/cpan-v5.6.0-blue.svg)](https://metacpan.org/pod/Sisimai)
[![codecov](https://codecov.io/github/sisimai/p5-sisimai/branch/5-stable/graph/badge.svg?token=8kvF4rWPM3)](https://codecov.io/github/sisimai/p5-sisimai)

> [!IMPORTANT]
> **2024年2月2日の時点でこのリポジトリのデフォルトブランチは[5-stable](https://github.com/sisimai/p5-sisimai/tree/5-stable)
> (Sisimai 5)になりました。** もし古いバージョンを使いたい場合は[4-stable](https://github.com/sisimai/p5-sisimai/tree/4-stable)[^1]
> ブランチを見てください。また`main`や`master`ブランチはもうこのリポジトリでは使用していません。
[^1]: 4系を`clone`する場合は`git clone -b 4-stable https://github.com/sisimai/p5-sisimai.git`

> [!CAUTION]
> **Sisimai 4.25.14p11およびそれ以前のバージョンには 正規表現に関する脆弱性
> [ReDoS: CVE-2022-4891](https://jvndb.jvn.jp/ja/contents/2022/JVNDB-2022-005663.html)があります。
> 該当するバージョンをお使いの場合はv4.25.14p12以降へアップグレードしてください。**

> [!WARNING]
> Sisimai 5はPerl 5.26以上が必要です。インストール/アップグレードを実行する前に`perl -v`コマンドで
> システムに入っているPerlのバージョンを確認してください。

> [!NOTE]
> SisimaiはPerlモジュールまたはRuby Gemですが、PHPやPython、GoやRustなどJSONを読める言語であれば
> どのような環境においても解析結果を得ることでバウンスの発生状況を捉えるのにとても有用です。

- [**🇬🇧README**](README.md)
- [シシマイ? | What is Sisimai](#what-is-sisimai)
    - [主な特徴的機能 | The key features of Sisimai](#the-key-features-of-sisimai)
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
- [Sisimai 4とSisimai 5の違い](#differences-between-sisimai-4-and-sisimai-5)
    - [機能など](#features)
    - [解析メソッド](#decoding-methods)
    - [MTA/ESPモジュール](#mtaesp-module-names)
    - [バウンス理由](#bounce-reasons)
- [Contributing](#contributing)
    - [バグ報告 | Bug report](#bug-report)
    - [解析できないメール | Emails could not be decoded](#emails-could-not-be-decoded)
- [その他の情報 | Other Information](#other-information)
    - [関連サイト | Related sites](#related-sites)
    - [参考情報 | See also](#see-also)
- [作者 | Author](#author)
- [著作権 | Copyright](#copyright)
- [ライセンス | License](#license)

What is sisimai
===================================================================================================
Sisimai(シシマイ)は複雑で多種多様なバウンスメールを解析してバウンスした理由や宛先メールアドレスなど
配信が失敗した結果を構造化データで出力するライブラリでJSONでの出力も可能です

![](https://libsisimai.org/static/images/figure/sisimai-overview-2.png)

The key features of Sisimai
---------------------------------------------------------------------------------------------------
* __バウンスメールを構造化したデータに変換__
  * 以下27項目の情報を含むデータ構造[^2]
    * __基本的情報__: `timestamp`, `origin`
    * __発信者情報__: `addresser`, `senderdomain`, 
    * __受信者情報__: `recipient`, `destination`, `alias`
    * __配信の情報__: `action`, `replycode`, `deliverystatus`, `command`
    * __エラー情報__: `reason`, `diagnosticcode`, `diagnostictype`, `feedbacktype`, `feedbackid`, `hardbounce`
    * __メール情報__: `subject`, `messageid`, `listid`,
    * __その他情報__: `decodedby`, `timezoneoffset`, `lhost`, `rhost`, `token`, `catch`
  * __出力可能な形式__
    * Perl (Hash, Array)
    * JSON ([`JSON`](https://metacpan.org/pod/JSON)モジュールを使用)
    * YAML ([`YAML`](https://metacpan.org/dist/YAML/view/lib/YAML.pod)モジュールまたは
            [`YAML::Syck`](https://metacpan.org/pod/YAML::Syck)モジュールが必要)
* __インストールも使用も簡単__
  * `cpan`, `cpanm`, `cpm install`
  * `git clone & make`
* __高い解析精度__
  * [60種類のMTAs/MDAs/ESPs](https://libsisimai.org/en/engine/)に対応
  * Feedback Loop(ARF)にも対応
  * [34種類のバウンス理由](https://libsisimai.org/en/reason/)を検出

[^2]: コールバック機能を使用すると`catch`アクセサの下に独自のデータを追加できます

Command line demo
---------------------------------------------------------------------------------------------------
次の画像のように、Perl版シシマイ(p5-sisimai)はコマンドラインから簡単にバウンスメールを解析すること
ができます。
![](https://libsisimai.org/static/images/demo/sisimai-5-cli-dump-p01.gif)

Setting Up Sisimai
===================================================================================================
System requirements
---------------------------------------------------------------------------------------------------
シシマイの動作環境についての詳細は[Sisimai | シシマイを使ってみる](https://libsisimai.org/ja/start/)
をご覧ください。

* [Perl 5.26.0 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)

Install
---------------------------------------------------------------------------------------------------
### From CPAN
```shell
$ cpanm --sudo Sisimai
--> Working on Sisimai
Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-5.6.0.tar.gz ... OK
...
1 distribution installed
$ perldoc -l Sisimai
/usr/local/lib/perl5/site_perl/5.30.0/Sisimai.pm
```

### From GitHub
> [!WARNING]
> Sisimai 5はPerl 5.26以上が必要です。インストール/アップグレードを実行する前に`perl -v`コマンドで
> システムに入っているPerlバージョンを確認してください。

```shell
$ perl -v

This is perl 5, version 30, subversion 0 (v5.30.0) built for darwin-2level

Copyright 1987-2019, Larry Wall
...

$ cd /usr/local/src
$ git clone https://github.com/sisimai/p5-sisimai.git
$ cd ./p5-sisimai

$ make install-from-local
./cpanm --sudo . || ( make cpm && ./cpm install --sudo -v . )
--> Working on .
Configuring Sisimai-v5.6.0 ... OK
Building and testing Sisimai-v5.6.0 ... Password: <sudo password here>
OK
Successfully installed Sisimai-v5.6.0
1 distribution installed

$ perl -MSisimai -lE 'print Sisimai->version'
5.6.0
```

Usage
===================================================================================================
Basic usage
---------------------------------------------------------------------------------------------------
下記のようにSisimaiの`rise()`メソッドをmboxかMaildir/のPATHを引数にして実行すると解析結果が配列
リファレンスで返ってきます。v4.25.6から元データとなった電子メールファイルへのPATHを保持する`origin`
が利用できます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $v = Sisimai->rise('/path/to/mbox'); # またはMaildir/へのPATH

# v4.23.0からSisimaiクラスのrise()メソッドとdump()メソッドはPATH以外にもバウンスメール全体を文字列
# として読めるようになりました
use IO::File;
my $r = '';
my $f = IO::File->new('/path/to/mbox'); # またはMaildir/へのPATH
{ local $/ = undef; $r = <$f>; $f->close }
my $v = Sisimai->rise(\$r);

# もし"delivered"(配信成功)となる解析結果も必要な場合は以下に示すとおりrise()メソッドに"delivered"
# オプションを指定してください
my $v = Sisimai->rise('/path/to/mbox', 'delivered' => 1);

# v5.0.0からSisimaiはバウンス理由が"vacation"となる解析結果をデフォルトで返さなくなりました。もし
# "vacation"となる解析結果も必要な場合は次のコードで示すようにrise()メソッドに"vacation"オプション
# を指定してください。
my $v = Sisimai->rise('/path/to/mbox', 'vacation' => 1);

if( defined $v ) {
    for my $e ( @$v ) {
        print ref $e;                   # Sisimai::Fact
        print ref $e->recipient;        # Sisimai::Address
        print ref $e->timestamp;        # Sisimai::Time

        print $e->addresser->address;   # "michitsuna@example.org" # From
        print $e->recipient->address;   # "kijitora@example.jp"    # To
        print $e->recipient->host;      # "example.jp"
        print $e->deliverystatus;       # "5.1.1"
        print $e->replycode;            # "550"
        print $e->reason;               # "userunknown"
        print $e->origin;               # "/var/spool/bounce/new/1740074341.eml"
        print $e->hardbounce;           # 0

        my $h = $e->damn();             # Hashリファレンスに変換
        my $j = $e->dump('json');       # JSON(文字列)に変換
        print $e->dump('json');         # JSON化したバウンスメールの解析結果を表示
    }
}
```

Convert to JSON
---------------------------------------------------------------------------------------------------
下記のようにSisimaiの`dump()`メソッドをmboxかMaildir/のPATHを引数にして実行すると解析結果が文字列
(JSON)で返ってきます。

```perl
# メールボックスまたはMaildir/から解析した結果をJSONにする
my $j = Sisimai->dump('/path/to/mbox'); # またはMaildir/へのPATH
                                        # dump()メソッドはv4.1.27で追加されました
print $j;                               # JSON化した解析結果を表示

# dump()メソッドは"delivered"オプションや"vacation"オプションも指定可能
my $j = Sisimai->dump('/path/to/mbox', 'delivered' => 1, 'vacation' => 1);
```

Callback feature
---------------------------------------------------------------------------------------------------
`Sisimai->rise`と`Sisimai->dump`の`c___`引数(`c`と`_`が三個/魚用の釣り針に見える)はコールバック機能
で呼び出されるコードリファンレンスを保持する配列リファレンスです。
`c___`の1番目の要素には`Sisimai::Message->sift`で呼び出されるコードリファレンスでメールヘッダと本文
に対して行う処理を、2番目の要素には、解析対象のメールファイルに対して行う処理をそれぞれ入れます。

各コードリファレンスで処理した結果は`Sisimai::Fact->catch`を通して得られます。

### [0] メールヘッダと本文に対して
`c___`に渡す配列リファレンスの最初の要素に入れたコードリファレンスは`Sisimai::Message->sift()`で
呼び出されます。

```perl
#! /usr/bin/env perl
use Sisimai;
my $code = sub {
    my $args = shift;               # (*Hash)
    my $head = $args->{'headers'};  # (*Hash)  メールヘッダー
    my $body = $args->{'message'};  # (String) メールの本文
    my $adds = { 'x-mailer' => '', 'queue-id' => '' };

    if( $body =~ m/^X-Postfix-Queue-ID:\s*(.+)$/m ) {
        $adds->{'queue-id'} = $1;
    }

    $adds->{'x-mailer'} = $head->{'x-mailer'} || '';
    return $adds;
};
my $data = Sisimai->rise('/path/to/mbox', 'c___' => [$code, undef]);
my $json = Sisimai->dump('/path/to/mbox', 'c___' => [$code, undef]);

print $data->[0]->catch->{'x-mailer'};    # "Apple Mail (2.1283)"
print $data->[0]->catch->{'queue-id'};    # "43f4KX6WR7z1xcMG"
```

### [1] 各メールのファイルに対して
`Sisimai->rise()`と`Sisimai->dump()`の両メソッドに渡せる引数`c___`(配列リファレンス)の2番目に入れた
コードリファレンスは解析したメールのファイルごとに呼び出されます。

```perl
my $path = '/path/to/maildir';
my $code = sub {
    my $args = shift;           # (*Hash)
    my $kind = $args->{'kind'}; # (String)  Sisimai::Mail->kind
    my $mail = $args->{'mail'}; # (*String) Entire email message
    my $path = $args->{'path'}; # (String)  Sisimai::Mail->path
    my $fact = $args->{'fact'}; # (*Array)  List of Sisimai::Fact

    for my $e ( @$fact ) {
        # "catch"アクセサの中に独自の情報を保存する
        $e->{'catch'} ||= {};
        $e->{'catch'}->{'size'} = length $$mail;
        $e->{'catch'}->{'kind'} = ucfirst $kind;

        if( $$mail =~ /^Return-Path: (.+)$/m ) {
            # Return-Path: <MAILER-DAEMON>
            $e->{'catch'}->{'return-path'} = $1;
        }

        # "X-Sisimai-Parsed:"ヘッダーを追加して別のPATHに元メールを保存する
        my $a = sprintf("X-Sisimai-Parsed: %d\n", scalar @$fact);
        my $p = sprintf("/path/to/another/directory/sisimai-%s.eml", $e->token);
        my $f = IO::File->new($p, 'w');
        my $v = $$mail; $v =~ s/^(From:.+)$/$a$1/m;
        print $f $v; $f->close;
    }

    # 解析が終わったらMaildir/にあるファイルを削除する
    unlink $path if $kind eq 'maildir';

    # 特に何か値をReturnする必要はない
};

my $list = Sisimai->rise($path, 'c___' => [undef, $code]);
print $list->[0]->{'catch'}->{'size'};          # 2202
print $list->[0]->{'catch'}->{'kind'};          # "Maildir"
print $list->[0]->{'catch'}->{'return-path'};   # "<MAILER-DAEMON>"
```

コールバック機能のより詳細な使い方は
[Sisimai | 解析方法 - コールバック機能](https://libsisimai.org/ja/usage/#callback)をご覧ください。

One-Liner
---------------------------------------------------------------------------------------------------
Sisimai 4.1.27から登場した`dump()`メソッドを使うとワンライナーでJSON化した解析結果が得られます。

```shell
$ perl -MSisimai -lE 'print Sisimai->dump(shift)' /path/to/mbox
```

Output example
---------------------------------------------------------------------------------------------------
![](https://libsisimai.org/static/images/demo/sisimai-5-cli-dump-p01.gif)

```json
[
  {
    "destination": "google.example.com",
    "lhost": "gmail-smtp-in.l.google.com",
    "hardbounce": 0,
    "reason": "authfailure",
    "catch": null,
    "addresser": "michitsuna@example.jp",
    "alias": "nekochan@example.co.jp",
    "decodedby": "Postfix",
    "command": "DATA",
    "senderdomain": "example.jp",
    "listid": "",
    "action": "failed",
    "feedbacktype": "",
    "messageid": "hwK7pzjzJtz0RF9Y@relay3.example.com",
    "origin": "./gmail-5.7.26.eml",
    "recipient": "kijitora@google.example.com",
    "rhost": "gmail-smtp-in.l.google.com",
    "subject": "Nyaan",
    "timezoneoffset": "+0900",
    "replycode": 550,
    "token": "84656774898baa90660be3e12fe0526e108d4473",
    "toxic": false,
    "diagnostictype": "SMTP",
    "timestamp": 1650119685,
    "diagnosticcode": "host gmail-smtp-in.l.google.com[64.233.187.27] said: This mail has been blocked because the sender is unauthenticated. Gmail requires all senders to authenticate with either SPF or DKIM. Authentication results: DKIM = did not pass SPF [relay3.example.com] with ip: [192.0.2.22] = did not pass For instructions on setting up authentication, go to https://support.google.com/mail/answer/81126#authentication c2-202200202020202020222222cat.127 - gsmtp (in reply to end of DATA command)",
    "deliverystatus": "5.7.26"
  }
]
```


Differences between Sisimai 4 and Sisimai 5
===================================================================================================
[Sisimai 4.25.16p1](https://github.com/sisimai/p5-sisimai/releases/tag/v4.25.16p1)と
[Sisimai 5](https://github.com/sisimai/p5-sisimai/releases/tag/v5.0.0)には下記のような違いがあります。
それぞれの詳細は[Sisimai | 違いの一覧](https://libsisimai.org/ja/diff/)を参照してください。

Features
---------------------------------------------------------------------------------------------------
Sisimai 5.0.0から**Perl 5.26.0以上**が必要になります。

| 機能                                                 | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| 動作環境(Perl)                                       | 5.10 -             | **5.26** -          |
| 元メールファイルを操作可能なコールバック機能         | なし               | あり[^3]            |
| 解析エンジン(MTA/ESPモジュール)の数                  | 68                 | 60                  |
| 検出可能なバウンス理由の数                           | 29                 | 34                  |
| 依存もジュール数(Perlのコアモジュールを除く)         | 2 モジュール       | 2 モジュール        |
| ソースコードの行数                                   | 10,800 行          | 9,750 行            |
| テスト件数(t/とxt/ディレクトリ)                      | 270,000 件         | 340,000 件          |
| 1秒間に解析できるバウンスメール数[^4]                | 750 通             | 750 通              |
| ライセンス                                           | 2条項BSD           | 2条項BSD            |
| 開発会社による商用サポート                           | 提供中             | 提供中              |

[^3]: `Sisimai->rise`メソッドで指定する`c___`パラメーター第二引数で指定可能
[^4]: macOS Monterey/1.6GHz Dual-Core Intel Core i5/16GB-RAM/Perl 5.30

Decoding Method 
---------------------------------------------------------------------------------------------------
いくつかの解析メソッド名、クラス名、パラメーター名がSisimai 5で変更になっています。解析済みデータの
各項目は[LIBSISIMAI.ORG/JA/DATA](https://libsisimai.org/ja/data/)を参照してください。

| 解析用メソッド周辺の変更箇所                         | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| 解析メソッド名                                       | `Sisimai->make`    | `Sisimai->rise`     |
| 出力メソッド名                                       | `Sisimai->dump`    | `Sisimai->dump`     |
| 解析メソッドが返すオブジェクトのクラス               | `Sisimai::Data`    | `Sisimai::Fact`     |
| コールバック用のパラメーター名                       | `hook`             | `c___`[^5]          |
| ハードバウンスかソフトバウンスかを識別するメソッド名 | `softbounce`       | `hardbounce`        |
| "vacation"をデフォルトで検出するかどうか             | 検出する           | 検出しない          |
| Sisimai::Messageがオブジェクトを返すかどうか         | 返す               | 返さない            |
| MIME解析用クラスの名前                               | `Sisimai::MIME`    | `Sisimai::RFC2045`  |
| SMTPセッションの解析をするかどうか                   | しない             | する[^6]            |

[^5]: `c___`は漁港で使う釣り針に見える
[^6]: `Sisimai::SMTP::Transcript->rise`メソッドによる

MTA/ESP Module Names
---------------------------------------------------------------------------------------------------
Sisimai 5で3個のESPモジュール名(解析エンジン)が変更になりました。詳細はMTA/ESPモジュールの一覧/
[LIBSISIMAI.ORG/JA/ENGINE](https://libsisimai.org/ja/engine/)を参照してください。

| `Sisimai::`                                     | Sisimai 4               | Sisimai 5           |
|-------------------------------------------------|-------------------------|---------------------|
| Apple iCloud Mail (added at v5.1.0)             | なし                    | `Rhost::Apple`      |
| Microsoft Exchange Online                       | `Rhost::ExchangeOnline` | `Rhost::Microsoft`  |
| Google Workspace                                | `Rhost::GoogleApps`     | `Rhost::Google`     |
| Tencent                                         | `Rhost::TencentQQ`      | `Rhost::Tencent`    |
| Yahoo Mail (added at v5.1.0)                    | なし                    | `Rhost::YahooInc`   |
| Zoho (added at v5.5.0)                          | なし                    | `Rhost::Zoho`       |
| DragonFly Mail Agent (added at v5.1.0)          | なし                    | `Lhost::DragonFly`  |
| Mimecast (added at v5.5.0)                      | なし                    | `Lhost::Mimecast`   |

Bounce Reasons
---------------------------------------------------------------------------------------------------
Sisimai 5では新たに5個のバウンス理由が増えました。検出可能なバウンス理由の一覧は
[LIBSISIMAI.ORG/JA/REASON](https://libsisimai.org/en/reason/)を参照してください。

| バウンスした理由                                     | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| ドメイン認証によるもの(SPF,DKIM,DMARC)               | `SecurityError`    | `AuthFailure`       |
| 送信者のドメイン・IPアドレスの低いレピュテーション   | `Blocked`          | `BadReputation`     |
| PTRレコードが未設定または無効なPTRレコード           | `Blocked`          | `RequirePTR`        |
| RFCに準拠していないメール[^7]                        | `SecurityError`    | `NotCompliantRFC`   |
| STARTTLS関連のエラー (added at v5.2.0)               | `SecurityError`    | `FailedSTARTTLS`    |
| 単位時間の流量制限・送信速度が速すぎる               | `SecurityError`    | `RateLimited`       |
| セッションあたりの受信者数制限や接続数を超過         | `TooManyConn`      | `RateLimited`       |
| メールが大きすぎる(ExceedLimit)                      | `ExceedLimit`      | `EmailTooLarge`     |
| メールが大きすぎる(MesgTooBig)                       | `MesgTooBig`       | `EmailTooLarge`     |
| 宛先がサプレッションリストに一致 (added at v5.2.0)   | `OnHold`           | `Suppressed`        |

[^7]: RFC5322など


Contributing
===================================================================================================
Bug report
---------------------------------------------------------------------------------------------------
もしもSisimaiにバグを発見した場合は[Issues](https://github.com/sisimai/p5-sisimai/issues)にて連絡を
いただけると助かります。

Emails could not be decoded
---------------------------------------------------------------------------------------------------
Sisimaiで解析できないバウンスメールは
[set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet](https://github.com/sisimai/set-of-emails/tree/master/to-be-debugged-because/sisimai-cannot-parse-yet)リポジトリに追加してPull-Requestを送ってください。


Other Information
===================================================================================================
Related sites
---------------------------------------------------------------------------------------------------
* __@libsisimai__ | [Sisimai on Twitter (@libsisimai)](https://twitter.com/libsisimai)
* __LIBSISIMAI.ORG__ | [SISIMAI | MAIL ANALYZING INTERFACE | DECODING BOUNCES, BETTER AND FASTER.](https://libsisimai.org/)
* __Facebook Page__ | [facebook.com/libsisimai](https://www.facebook.com/libsisimai/)
* __GitHub__ | [github.com/sisimai/p5-sisimai](https://github.com/sisimai/p5-sisimai)
* __CPAN__ | [Sisimai - Mail Analyzing Interface for bounce mails. - metacpan.org](https://metacpan.org/pod/Sisimai)
* __CPAN Testers Reports__ | [CPAN Testers Reports: Reports for Sisimai](http://cpantesters.org/distro/S/Sisimai.html)
* __Ruby verson__ | [Ruby version of Sisimai](https://github.com/sisimai/rb-sisimai)
* __Go verson__ | [Go version of Sisimai](https://github.com/sisimai/go-sisimai)
* __Fixtures__ | [set-of-emails - Sample emails for "make test"](https://github.com/sisimai/set-of-emails)

See also
---------------------------------------------------------------------------------------------------
* [README.md - README.md in English(🇬🇧)](https://github.com/sisimai/p5-sisimai/blob/master/README.md)
* [RFC3463 - Enhanced Mail System Status Codes](https://tools.ietf.org/html/rfc3463)
* [RFC3464 - An Extensible Message Format for Delivery Status Notifications](https://tools.ietf.org/html/rfc3464)
* [RFC3834 - Recommendations for Automatic Responses to Electronic Mail](https://tools.ietf.org/html/rfc3834)
* [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC5322 - Internet Message Format](https://tools.ietf.org/html/rfc5322)

Author
===================================================================================================
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

Copyright
===================================================================================================
Copyright (C) 2014-2026 azumakuniyuki, All Rights Reserved.

License
===================================================================================================
This software is distributed under The BSD 2-Clause License.

