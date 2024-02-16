![](https://libsisimai.org/static/images/logo/sisimai-x01.png)
[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/sisimai/p5-sisimai/blob/master/LICENSE)
[![Coverage Status](https://img.shields.io/coveralls/sisimai/p5-sisimai.svg)](https://coveralls.io/r/sisimai/p5-sisimai)
[![Perl](https://img.shields.io/badge/perl-v5.26--v5.38-blue.svg)](https://www.perl.org)
[![CPAN](https://img.shields.io/badge/cpan-v4.25.16-blue.svg)](https://metacpan.org/pod/Sisimai)

> [!IMPORTANT]
> **The default branch of this repository is [5-stable](https://github.com/sisimai/p5-sisimai/tree/5-stable)
> (Sisimai 5) since 2nd February 2024.**
> If you want to clone the old version, see the [4-stable](https://github.com/sisimai/p5-sisimai/tree/4-stable)[^1]
> branch instead. We have moved away from using both the `main` and `master` branches in our development process.
[^1]: Specify `-b 4-stable` when you clone Sisimai 4 for example, `git clone -b 4-stable https://github.com/sisimai/p5-sisimai.git`

> [!WARNING]
> Sisimai 5 requires Perl 5.26 or later. Check the version of Perl in your system before installing/upgrading
> by `perl -v` command.

> [!CAUTION]
> [Sisimai 5](https://github.com/sisimai/p5-sisimai/releases/tag/v5.0.0) has not been uploaded to
> [CPAN](https://metacpan.org/pod/Sisimai) yet as of February 2nd. It will be available on CPAN
> within a few months, but until then, please clone it from this repository.

- [**README-JA(日本語)**](README-JA.md)
- [What is Sisimai](#what-is-sisimai)
    - [The key features of Sisimai](#the-key-features-of-sisimai)
    - [Command line demo](#command-line-demo)
- [Setting Up Sisimai](#setting-up-sisimai)
    - [System requirements](#system-requirements)
    - [Install](#install)
        - [From CPAN](#from-cpan)
        - [From GitHub](#from-github)
- [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [Convert to JSON](#convert-to-json)
    - [Callback feature](#callback-feature)
    - [One-Liner](#one-liner)
    - [Output example](#output-example)
- [Differences between Sisimai 4 and Sisimai 5](#differences-between-sisimai-4-and-sisimai-5)
    - [Features](#features)
    - [Decoding Methods](#decoding-methods)
    - [MTA/ESP Module Names](#mtaesp-module-names)
    - [Bounce Reasons](#bounce-reasons)
- [Contributing](#contributing)
    - [Bug report](#bug-report)
    - [Emails could not be decoded](#emails-could-not-be-decoded)
- [Other Information](#other-information)
    - [Related sites](#related-sites)
    - [See also](#see-also)
- [Author](#author)
- [Copyright](#copyright)
- [License](#license)


What is Sisimai
===================================================================================================
Sisimai is a library that decodes complex and diverse bounce emails and outputs the results of the
delivery failure, such as the reason for the bounce and the recipient email address, in structured
data. It is also possible to output in JSON format.

![](https://libsisimai.org/static/images/figure/sisimai-overview-1.png)

The key features of Sisimai
---------------------------------------------------------------------------------------------------
* __Decode email bounces to structured data__
  * Sisimai provides detailed insights into bounce emails by extracting 24 key data points.[^2]
    * __Essential information__: `timestamp`, `origin`
    * __Sender information__: `addresser`, `senderdomain`, 
    * __Recipient information__: `recipient`, `destination`, `alias`
    * __Delivery information__: `action`, `replycode`,`action`, `replycode`, `deliverystatus`
    * __Bounce details__: `reason`, `diagnosticcode`, `diagnostictype`, `feedbacktype`, `hardbounce`
    * __Message details__: `subject`, `messageid`, `listid`,
    * __Additional information__: `smtpagent`, `timezoneoffset`, `lhost`, `rhost`, `token`, `catch`
  * Output formats
    * Perl (Hash, Array)
    * JSON (by using [`JSON`](https://metacpan.org/pod/JSON) module)
    * YAML ([`YAML`](https://metacpan.org/dist/YAML/view/lib/YAML.pod) module or 
            [`YAML::Syck`](https://metacpan.org/pod/YAML::Syck) module required)
* __Easy to Install, Use.__
  * `cpan`, `cpanm`, or `cpm`
  * `git clone & make`
* __High Precision of Analysis__
  * Support [70 MTAs/MDAs/ESPs](https://libsisimai.org/en/engine/)
  * Support Feedback Loop Message(ARF)
  * Can detect [34 bounce reasons](https://libsisimai.org/en/reason/)

[^2]: The callback function allows you to add your own data under the `catch` accessor.

Command line demo
---------------------------------------------------------------------------------------------------
The following screen shows a demonstration of `dump` method of Sisimai 5 at the command line using
Perl(p5-sisimai) and `jq` command.
![](https://libsisimai.org/static/images/demo/sisimai-5-cli-dump-p01.gif)

Setting Up Sisimai
===================================================================================================
System requirements
---------------------------------------------------------------------------------------------------
More details about system requirements are available at
[Sisimai | Getting Started](https://libsisimai.org/en/start/) page.

* [Perl 5.26.0 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)

Install
---------------------------------------------------------------------------------------------------
### From CPAN
> [!CAUTION]
> [Sisimai 5](https://github.com/sisimai/p5-sisimai/releases/tag/v5.0.0) has not been uploaded to
> [CPAN](https://metacpan.org/pod/Sisimai) yet as of February 2nd. It will be available on CPAN
> within a few months, but until then, please clone it from this repository.

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
> [!WARNING]
> Sisimai 5 requires Perl 5.26 or later. Check the version of Perl in your system before installing/upgrading
> by `perl -v` command.

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
Configuring Sisimai-v5.0.0 ... OK
Building and testing Sisimai-v5.0.0 ... Password: <sudo password here>
OK
Successfully installed Sisimai-v5.0.0
1 distribution installed

$ perl -MSisimai -lE 'print Sisimai->version'
5.0.0
```

Usage
===================================================================================================
Basic usage
---------------------------------------------------------------------------------------------------
`Sisimai->rise()` method provides the feature for getting decoded data as Perl Hash reference from
bounced email messages as the following. Beginning with v4.25.6, new accessor `origin` which keeps
the path to email file as a data source is available.

```perl
#! /usr/bin/env perl
use Sisimai;
my $v = Sisimai->rise('/path/to/mbox'); # or path to Maildir/


# In v4.23.0, the rise() and dump() methods of the Sisimai class can now read the entire bounce
# email as a string, in addition to the PATH to the email file or mailbox.
use IO::File;
my $r = '';
my $f = IO::File->new('/path/to/mbox'); # or path to Maildir/
{ local $/ = undef; $r = <$f>; $f->close }
my $v = Sisimai->rise(\$r);

# If you also need analysis results that are "delivered" (successfully delivered), please specify
# the "delivered" option to the rise() method as shown below.
my $v = Sisimai->rise('/path/to/mbox', 'delivered' => 1);

# From v5.0.0, Sisimai no longer returns analysis results with a bounce reason of "vacation" by
# default. If you also need analysis results that show a "vacation" reason, please specify the
# "vacation" option to the rise() method as shown in the following code.
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
        print $e->hardbounce;           # 1

        my $h = $e->damn();             # Convert to HASH reference
        my $j = $e->dump('json');       # Convert to JSON string
        print $e->dump('json');         # JSON formatted bounce data
    }
}
```

Convert to JSON
---------------------------------------------------------------------------------------------------
`Sisimai->dump()` method provides the feature for getting decoded data as JSON string from bounced
email messages like the following code:

```perl
#! /usr/bin/env perl
use Sisimai;

# Get JSON string from path of a mailbox or a Maildir/
my $j = Sisimai->dump('/path/to/mbox'); # or path to Maildir/
                                        # dump() is added in v4.1.27
print $j;                               # decoded data as JSON

# dump() method also accepts "delivered" and "vacation" option like the following code:
my $j = Sisimai->dump('/path/to/mbox', 'delivered' => 1, 'vacation' => 1);
```

Callback feature
---------------------------------------------------------------------------------------------------
`c___` (`c` and three `_`s, looks like a fishhook) argument of `Sisimai->rise` and `Sisimai->dump`
is an array reference and is a parameter to receive code references for callback feature. The first
element of `c___` argument is called at `Sisimai::Message->sift` for dealing email headers and 
entire message body. The second element of `c___` argument is called at the end of each email file
parsing. The result generated by the callback method is accessible via `Sisimai::Fact->catch`.

### [0] For email headers and the body
Callback method set in the first element of `c___` is called at `Sisimai::Message->sift()`.

```perl
#! /usr/bin/env perl
use Sisimai;
my $code = sub {
    my $args = shift;               # (*Hash)
    my $head = $args->{'headers'};  # (*Hash)  Email headers
    my $body = $args->{'message'};  # (String) Message body
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

### [1] For each email file
Callback method set in the second element of `c___` is called at `Sisimai->rise()` method for
dealing each email file.

```perl
my $path = '/path/to/maildir';
my $code = sub {
    my $args = shift;           # (*Hash)
    my $kind = $args->{'kind'}; # (String)  Sisimai::Mail->kind
    my $mail = $args->{'mail'}; # (*String) Entire email message
    my $path = $args->{'path'}; # (String)  Sisimai::Mail->path
    my $sisi = $args->{'sisi'}; # (*Array)  List of Sisimai::Fact

    for my $e ( @$sisi ) {
        # Store custom information in the "catch" accessor.
        $e->{'catch'} ||= {};
        $e->{'catch'}->{'size'} = length $$mail;
        $e->{'catch'}->{'kind'} = ucfirst $kind;

        if( $$mail =~ /^Return-Path: (.+)$/m ) {
            # Return-Path: <MAILER-DAEMON>
            $e->{'catch'}->{'return-path'} = $1;
        }

        # Save the original email with an additional "X-Sisimai-Parsed:" header to a different PATH.
        my $a = sprintf("X-Sisimai-Parsed: %d\n", scalar @$sisi);
        my $p = sprintf("/path/to/another/directory/sisimai-%s.eml", $e->token);
        my $f = IO::File->new($p, 'w');
        my $v = $$mail; $v =~ s/^(From:.+)$/$a$1/m;
        print $f $v; $f->close;
    }

    # Remove the email file in Maildir/ after decoding
    unlink $path if $kind eq 'maildir';

    # Need to not return a value
};

my $list = Sisimai->rise($path, 'c___' => [undef, $code]);
print $list->[0]->{'catch'}->{'size'};          # 2202
print $list->[0]->{'catch'}->{'kind'};          # "Maildir"
print $list->[0]->{'catch'}->{'return-path'};   # "<MAILER-DAEMON>"
```

More information about the callback feature is available at
[Sisimai | How To Parse - Callback](https://libsisimai.org/en/usage/#callback) Page.

One-Liner
---------------------------------------------------------------------------------------------------
Beginning with Sisimai 4.1.27, `Sisimai->dump()` method is available and you can get decoded data
as JSON using the method.

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
    "smtpagent": "Postfix",
    "smtpcommand": "DATA",
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
    "diagnostictype": "SMTP",
    "timestamp": 1650119685,
    "diagnosticcode": "host gmail-smtp-in.l.google.com[64.233.187.27] said: This mail has been blocked because the sender is unauthenticated. Gmail requires all senders to authenticate with either SPF or DKIM. Authentication results: DKIM = did not pass SPF [relay3.example.com] with ip: [192.0.2.22] = did not pass For instructions on setting up authentication, go to https://support.google.com/mail/answer/81126#authentication c2-202200202020202020222222cat.127 - gsmtp (in reply to end of DATA command)",
    "deliverystatus": "5.7.26"
  }
]
```

Differences between Sisimai 4 and Sisimai 5
===================================================================================================
The following table show the differences between [Sisimai 4.25.16p1](https://github.com/sisimai/p5-sisimai/releases/tag/v4.25.16p1)
and [Sisimai 5](https://github.com/sisimai/p5-sisimai/releases/tag/v5.0.0). More information about
differences are available at [Sisimai | Differences](https://libsisimai.org/en/diff/) page.

Features
---------------------------------------------------------------------------------------------------
Beginning with v5.0.0, Sisimai requires **Perl 5.26.0 or later.**

| Features                                             | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| System requirements (Perl)                           | 5.10 - 5.38        | **5.26** - 5.38     |
| Callback feature for the original email file         | N/A                | Available[^3]       |
| The number of MTA/ESP modules                        | 68                 | 70                  |
| The number of detectable bounce reasons              | 29                 | 34                  |
| Dependencies (Except core modules of Perl)           | 2 modules          | 2 modules           |
| Source lines of code                                 | 10,800 lines       | 11,400 lines        |
| The number of tests in t/, xt/ directory             | 270,000 tests      | 323,000 tests       | 
| The number of bounce emails decoded per second[^4]   | 541 emails         | 660 emails          |
| License                                              | 2 Clause BSD       | 2 Caluse BSD        |
| Commercial support                                   | Available          | Available           |

[^3]: The 2nd argument of `c___` parameter at `Sisimai->rise` method
[^4]: macOS Monterey/1.6GHz Dual-Core Intel Core i5/16GB-RAM/Perl 5.30

Decoding Method
---------------------------------------------------------------------------------------------------
Some decoding method names, class names, parameter names have been changed at Sisimai 5.
The details of the decoded data are available at [LIBSISIMAI.ORG/EN/DATA](https://libsisimai.org/en/data/)

| Decoding Method                                      | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| Decoding method name                                 | `Sisimai->make`    | `Sisimai->rise`     |
| Dumping method name                                  | `Sisimai->dump`    | `Sisimai->dump`     |
| Class name of decoded object                         | `Sisimai::Data`    | `Sisimai::Fact`     |
| Parameter name of the callback                       | `hook`             | `c___`[^5]          |
| Method name for checking the hard/soft bounce        | `softbounce`       | `hardbounce`        |
| Decode a vacation message by default                 | Yes                | No                  |
| Sisimai::Message returns an object                   | Yes                | No                  |
| MIME decoding class                                  | `Sisimai::MIME`    | `Sisimai::RFC2045`  |
| Decoding transcript of SMTP session                  | No                 | Yes[^6]             |

[^5]: `c___` looks like a fishhook
[^6]: `Sisimai::SMTP::Transcript->rise` Method provides the feature


MTA/ESP Module Names
---------------------------------------------------------------------------------------------------
Three ESP module names have been changed at Sisimai 5. The list of the all MTA/ESP modules is
available at [LIBSISIMAI.ORG/EN/ENGINE](https://libsisimai.org/en/engine/)

| `Sisimai::Rhost::`                                   | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| Microsoft Exchange Online                            | `ExchangeOnline`   | `Microsoft`         |
| Google Workspace                                     | `GoogleApps`       | `Google`            |
| Tencent                                              | `TencentQQ`        | `Tencent`           |


Bounce Reasons
---------------------------------------------------------------------------------------------------
Five bounce reasons have been added at Sisimai 5. The list of the all bounce reasons sisimai can
detect is available at [LIBSISIMAI.ORG/EN/REASON](https://libsisimai.org/en/reason/)

| Rejected due to                                      | Sisimai 4          | Sisimai 5           |
|------------------------------------------------------|--------------------|---------------------|
| sender domain authentication(SPF,DKIM,DMARC)         | `SecurityError`    | `AuthFailure`       |
| low/bad reputation of the sender hostname/IP addr.   | `Blocked`          | `BadReputation`     |
| missing PTR/having invalid PTR                       | `Blocked`          | `RequirePTR`        |
| non-compliance with RFC[^7]                          | `SecurityError`    | `NotCompliantRFC`   |
| exceeding a rate limit or sending too fast           | `SecurityError`    | `Speeding`          |

[^7]: RFC5322 and related RFCs


Contributing
===================================================================================================
Bug report
---------------------------------------------------------------------------------------------------
Please use the [issue tracker](https://github.com/sisimai/p5-sisimai/issues) to report any bugs.

Emails could not be decoded
---------------------------------------------------------------------------------------------------
Bounce mails which could not be decoded by Sisimai are saved in the repository
[set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet](https://github.com/sisimai/set-of-emails/tree/master/to-be-debugged-because/sisimai-cannot-parse-yet). 
If you have found any bounce email cannot be decoded using Sisimai, please add the email into the
directory and send Pull-Request to this repository.


Other Information
===================================================================================================
Related sites
---------------------------------------------------------------------------------------------------
* __@libsisimai__ | [Sisimai on Twitter (@libsisimai)](https://twitter.com/libsisimai)
* __LIBSISIMAI.ORG__ | [SISIMAI | MAIL ANALYZING INTERFACE | DECODING BOUNCES, BETTER AND FASTER.](https://libsisimai.org/)
* __Sisimai Blog__ | [blog.libsisimai.org](http://blog.libsisimai.org/)
* __Facebook Page__ | [facebook.com/libsisimai](https://www.facebook.com/libsisimai/)
* __GitHub__ | [github.com/sisimai/p5-sisimai](https://github.com/sisimai/p5-sisimai)
* __CPAN__ | [Sisimai - Mail Analyzing Interface for bounce mails. - metacpan.org](https://metacpan.org/pod/Sisimai)
* __CPAN Testers Reports__ | [CPAN Testers Reports: Reports for Sisimai](http://cpantesters.org/distro/S/Sisimai.html)
* __Ruby verson__ | [Ruby version of Sisimai](https://github.com/sisimai/rb-sisimai)
* __Fixtures__ | [set-of-emails - Sample emails for "make test"](https://github.com/sisimai/set-of-emails)

See also
---------------------------------------------------------------------------------------------------
* [README-JA.md - README.md in Japanese(日本語)](https://github.com/sisimai/p5-sisimai/blob/master/README-JA.md)
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
Copyright (C) 2014-2024 azumakuniyuki, All Rights Reserved.

License
===================================================================================================
This software is distributed under The BSD 2-Clause License.

