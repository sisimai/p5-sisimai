[![License](https://img.shields.io/badge/license-BSD%202--Clause-orange.svg)](https://github.com/sisimai/p5-Sisimai/blob/master/LICENSE)
[![Coverage Status](https://img.shields.io/coveralls/sisimai/p5-Sisimai.svg)](https://coveralls.io/r/sisimai/p5-Sisimai)
[![Build Status](https://travis-ci.org/sisimai/p5-Sisimai.svg?branch=master)](https://travis-ci.org/sisimai/p5-Sisimai) 
[![Perl](https://img.shields.io/badge/perl-v5.10--v5.22-blue.svg)](https://www.perl.org)
[![CPAN](https://img.shields.io/badge/cpan-v4.18.1-blue.svg)](https://metacpan.org/pod/Sisimai)

![](http://41.media.tumblr.com/45c8d33bea2f92da707f4bbe66251d6b/tumblr_nuf7bgeyH51uz9e9oo1_1280.png)

What is Sisimai
===============
Sisimai is a Perl module for analyzing RFC5322 bounce emails and generating
structured data from parsed results. Sisimai is the system formerly known as
bounceHammer 4. __Sisimai__ is a coined word: Sisi (the number 4 is pronounced
__Si__ in Japanese) and MAI (acronym of __Mail Analyzing Interface__).

Key Features
------------
* __Convert Bounce Mails to Structured Data__
  * Supported formats are Perl and JSON
* __Easy to Install, Use.__
  * cpanm
  * git clone & make
* __High Precision of Analysis__
  * 2 times higher than bounceHammer
  * Support 22 known MTAs and 5 unknown MTAs
  * Support 21 major MSPs(Mail Service Providers)
  * Support Feedback Loop Message(ARF)
  * Can detect 27 error reasons
* __Faster than bounceHammer version 2.7.13p3__
  * About 1.7 times faster


Setting Up Sisimai
==================
System requirements
-------------------
More details about system requirements are available at
[Sisimai | Getting Started](http://libsisimai.org/en/start) page.

* [Perl 5.10.1 or later](http://www.perl.org/)
* [__Class::Accessor::Lite__](https://metacpan.org/pod/Class::Accessor::Lite)
* [__JSON__](https://metacpan.org/pod/JSON)


Install
-------
### From CPAN

```shell
% sudo cpanm Sisimai
--> Working on Sisimai
Fetching http://www.cpan.org/authors/id/A/AK/AKXLIX/Sisimai-4.14.0.tar.gz ... OK
...
1 distribution installed
% perldoc -l Sisimai
/usr/local/lib/perl5/site_perl/5.20.0/Sisimai.pm
```

### From GitHub

```shell
% cd /usr/local/src
% git clone https://github.com/sisimai/p5-Sisimai.git
% cd ./p5-Sisimai
% sudo make install-from-local
--> Working on .
Configuring Sisimai-4.14.0 ... OK
1 distribution installed
```

Usage
=====
Basic usage
-----------
`make()` method provides feature for getting parsed data from bounced email 
messages like following.

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

```json
[{"rhost": "mx.example.co.jp","recipient": "filtered@example.co.jp","token": "01b88ad40b2f7089a6b1986ade14d323aaad9da2","deliverystatus": "5.2.1","smtpcommand": "RCPT","alias": "filtered@example.co.jp","addresser": "kijitora@example.jp","subject": "test","smtpagent": "Postfix","messageid": "","diagnosticcode": "550 5.2.1 <filtered@example.co.jp>... User Unknown","lhost": "smtp.example.com","replycode": "550","reason": "userunknown","destination": "example.co.jp","action": "failed","softbounce": 0,"timezoneoffset": "+0000","diagnostictype": "SMTP","feedbacktype": "","listid": "","timestamp": 1403375674,"senderdomain": "example.jp"},{"lhost": "smtp.example.com","reason": "userunknown","replycode": "550","destination": "example.co.jp","action": "failed","softbounce": 0,"timezoneoffset": "+0000","diagnostictype": "SMTP","feedbacktype": "","listid": "","timestamp": 1403375674,"senderdomain": "example.jp","rhost": "mx.example.co.jp","recipient": "userunknown@example.co.jp","deliverystatus": "5.1.1","token": "948ed89b794207632dbab0ce3b72175553d9de83","smtpcommand": "RCPT","alias": "userunknown@example.co.jp","addresser": "kijitora@example.jp","subject": "test","smtpagent": "Postfix","messageid": "","diagnosticcode": "550 5.1.1 <userunknown@example.co.jp>... User Unknown"}]
```

One-Liner
---------
Beginning with Sisimai 4.1.27, `dump()` method is available and you can get parsed
data as JSON using the method.

```shell
% perl -MSisimai -lE 'print Sisimai->dump(shift)' /path/to/mbox
```


Sisimai Specification
=====================
Differences between ver.2 and Sisimai
-------------------------------------
The following table show the differences between ver.2 (bounceHammer 2.7.13p3)
and Sisimai. More information about differences are available at
[Sisimai | Differences](http://libsisimai.org/en/diff) page.

| Features                                       | bounceHammer  | Sisimai     |
|------------------------------------------------|---------------|-------------|
| System requirements(Perl)                      | 5.10 - 5.14   | 5.10 - 5.22 |
| Command line tools                             | Available     | N/A         |
| Modules for Commercial MTAs and MPSs           | N/A           | Included    |
| WebUI/API                                      | Included      | N/A         |
| Database schema for storing parsed bounce data | Available     | N/A[1]      |
| Analytical precision ratio(2000 emails)[2]     | 0.49          | 1.00        |
| The speed of parsing email(1000 emails)        | 4.24s         | 2.33s       |
| The number of detectable bounce reasons        | 19            | 27          |
| Parse 2 or more bounces in a single email      | Only 1st rcpt | ALL         |
| Parse FeedBack Loop Message/ARF format mail    | Unable        | OK          |
| Classification based on recipient domain       | Available     | N/A         |
| Output format of parsed data                   | YAML,JSON,CSV | JSON only   |
| Easy to install                                | No            | Yes         |
| Install using cpan or cpanm command            | N/A           | OK          |
| Dependencies (Except core modules of Perl)     | 24 modules    | 2 modules   |
| LOC:Source lines of code                       | 18200 lines   | 8500 lines  |
| The number of tests in t/, xt/ directory       | 27365 tests   | 177000 tests|
| License                                        | GPLv2 or Perl | 2 clause BSD|
| Support Contract provided by Developer         | End Of Sales  | Available   |

1. Implement yourself with using DBI or any O/R Mapper you like
2. See [./ANALYTICAL-PRECISION](https://github.com/sisimai/p5-Sisimai/blob/master/ANALYTICAL-PRECISION)


MTA/MSP Modules
---------------
The following table is the list of MTA/MSP:(Mail Service Provider) modules.
More details about these modules are available at 
[Sisimai | Parser Engines](http://libsisimai.org/en/engine) page.

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
| ARF                      | Abuse Feedback Reporting Format                   |
| RFC3464                  | Fallback Module for MTAs                          |
| RFC3834                  | Detector for auto replied message (> v4.1.28)     |

Bounce Reason List
------------------
Sisimai can detect the following 27 bounce reasons. More details about reasons
are available at [Sisimai | Bounce Reason List](http://libsisimai.org/en/reason)
page.

| Reason         | Description                            | Impelmented at     |
|----------------|----------------------------------------|--------------------|
| Blocked        | Blocked due to client IP address       |                    |
| ContentError   | Invalid format email                   |                    |
| Delivered[1]   | Successfully delivered                 | v4.16.0            |
| ExceedLimit    | Message size exceeded the limit(5.2.3) |                    |
| Expired        | Delivery time expired                  |                    |
| Feedback       | Bounced for a complaint of the message |                    |
| Filtered       | Rejected after DATA command            |                    |
| HasMoved       | Destination mail addrees has moved     |                    |
| HostUnknown    | Unknown destination host name          |                    |
| MailboxFull    | Recipient's mailbox is full            |                    |
| MailerError    | Mailer program error                   |                    |
| MesgTooBig     | Message size is too big(5.3.4)         |                    |
| NetworkError   | Network error: DNS or routing          |                    |
| NotAccept      | Destinaion does not accept any message |                    |
| OnHold         | Deciding the bounce reason is on hold  |                    |
| Rejected       | Rejected due to envelope from address  |                    |
| NoRelaying     | Relay access denied                    |                    |
| SecurityError  | Virus detected or authentication error |                    |
| SpamDetected   | Detected a message as spam             |                    |
| Suspend        | Recipient's account is suspended       |                    |
| SyntaxError    | syntax error in SMTP                   | v4.17.0            |
| SystemError    | Some error on the destination host     |                    |
| SystemFull     | Disk full on the destination host      |                    |
| TooManyConn    | Connection rate limit exceeded         |                    |
| UserUnknown    | Recipient's address does not exist     |                    |
| Undefined      | Could not decide the error reason      |                    |
| Vacation       | Auto replied message                   | v4.1.28            |

1. This reason is not included by default

Parsed data structure
---------------------
The following table shows a data structure (`Sisimai::Data`) of parsed bounce mail.
More details about data structure are available at available at 
[Sisimai | Data Structure of Sisimai::Data](http://libsisimai.org/en/data) page.

| Name           | Description                                                 |
|----------------|-------------------------------------------------------------|
| action         | The value of Action: header                                 |
| addresser      | The sender's email address (From:)                          |
| alias          | Alias of the recipient                                      |
| destination    | The domain part of the "recipinet"                          |
| deliverystatus | Delivery Status(DSN), ex) 5.1.1, 4.4.7                      |
| diagnosticcode | Error message                                               |
| diagnostictype | Error message type                                          |
| feedbacktype   | Feedback Type                                               |
| lhost          | local host name(local MTA)                                  |
| listid         | The value of List-Id: header of the original message        |
| messageid      | The value of Message-Id: of the original message            |
| reason         | Detected bounce reason                                      |
| recipient      | Recipient address which bounced (To:)                       |
| replycode      | SMTP Reply Code, ex) 550, 421                               |
| rhost          | Remote host name(remote MTA)                                |
| senderdomain   | The domain part of the "addresser"                          |
| softbounce     | The bounce is soft bounce or not: 0=hard,1=soft,-1=unknown  |
| smtpagent      | MTA module name (Sisimai::MTA::, MSP::)                     |
| smtpcommand    | The last SMTP command in the session                        |
| subject        | The vale of Subject: header of the original message(UTF8)   |
| timestamp      | Timestamp of the bounce, UNIX matchine time                 |
| timezoneoffset | Time zone offset string: ex) +0900                          |
| token          | MD5 value of addresser, recipient, and the timestamp        |


Emails could not be parsed
--------------------------
Bounce mails which could not be parsed by Sisimai are saved in the directory
`set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet`. 
If you have found any bounce email cannot be parsed using Sisimai, please add
the email into the directory and send Pull-Request to this repository.


Other Information
=================
Related Sites
-------------
* __@libsisimai__ | [Sisimai on Twitter (@libsisimai)](https://twitter.com/libsisimai)
* __libSISIMAI.ORG__ | [Sisimai | The Successor To bounceHammer, Library to parse bounce mails](http://libsisimai.org/)
* __GitHub__ | [github.com/sisimai/p5-Sisimai](https://github.com/sisimai/p5-Sisimai)
* __CPAN__ | [Sisimai - Mail Analyzing Interface for bounce mails. - metacpan.org](https://metacpan.org/pod/Sisimai)
* __CPAN Testers Reports__ | [CPAN Testers Reports: Reports for Sisimai](http://cpantesters.org/distro/S/Sisimai.html)
* __Ruby verson__ | [Ruby version of Sisimai](https://github.com/sisimai/rb-Sisimai)
* __bounceHammer.JP__ | [bounceHammer will be EOL on February 29, 2016](http://bouncehammer.jp/)

SEE ALSO
--------
* [README-JA.md - README.md in Japanese(日本語)](https://github.com/sisimai/p5-Sisimai/blob/master/README-JA.md)
* [RFC3463 - Enhanced Mail System Status Codes](https://tools.ietf.org/html/rfc3463)
* [RFC3464 - An Extensible Message Format for Delivery Status Notifications](https://tools.ietf.org/html/rfc3464)
* [RFC3834 - Recommendations for Automatic Responses to Electronic Mail](https://tools.ietf.org/html/rfc3834)
* [RFC5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC5322 - Internet Message Format](https://tools.ietf.org/html/rfc5322)

AUTHOR
------
[@azumakuniyuki](https://twitter.com/azumakuniyuki)

COPYRIGHT
---------
Copyright (C) 2014-2016 azumakuniyuki, All Rights Reserved.

LICENSE
-------
This software is distributed under The BSD 2-Clause License.

