RELEASE NOTES for Perl version of Sisimai
================================================================================
- releases: "https://github.com/sisimai/p5-Sisimai/releases"
- download: "https://metacpan.org/pod/Sisimai"
- document: "https://libsisimai.org/"

v4.25.0
--------------------------------------------------------------------------------
- release: "Tue,  9 Apr 2019 10:22:22 +0900 (JST)"
- version: "4.25.0"
- changes:
  - Implement new class `Sisimai::RFC1894` for parsing message/delivery-status
    part. #298
  - Experimental implementation at the following MTA, Rhost modules:
    - `Sisimai::Bite::Email::Amavis`: amavisd-new
    - `Sisimai::Rhost::TencentQQ`: Tencent QQ (mail.qq.com)
  - Sisimai works with JSON 4.00
  - Remove unused methods and variables
    - `Sisimai::DateTime->hourname`
    - `$Sisimai::DateTime::HourNames`
    - `Sisimai::RFC5322->is_domainpart`
    - `Sisimai::Address->is_undisclosed`
  - Code refactoring: less lines of code and shallower indentation.
  - Fix bug in `Sisimai::ARF` to resolve issue #304. Thanks to @lewa.
  - Remove `set-of-emails/logo` directory because we cannot change the license
    of each file in the directory to The 2-Clause BSD License.
  - Update error message patterns in the following modules:
    - `Sisimai::Reason::Blocked` (hotmail, ntt docomo)
    - `Sisimai::Reason::SystemError` (hotmail)
    - `Sisimai::Reason::TooManyConn` (ntt docomo)
    - `Sisimai::Reason::UserUnknown` (hotmail)
    - `Sisimai::Reason::PolicyViolation` (postfix)
    - `Sisimai::Bite::Email::McAfee` (userunknown)
    - `Sisimai::Bite::Email::Exchange2007` (securityerror)
  - Bug fix in `$Sisimai::Message::Email::TryOnFirst`: Module name to be loaded 
    is checked before calling `push` function for avoiding duplication.
  - The order of `Sisimai::Bite::Email` modules to be loaded has been changed:
    Load Office365 and Outlook prior to Exchange2007 and Exchange2003.
  - Update the followng MTA modules for improvements and bug fixes:
    - `Sisimai::Bite::Email::Exchange2007`
  - MIME Decoding in `Subject:` header improved.
  - Bug fix in `Sisimai::MIME->is_mimeencoded` method.
  - Make stable the order of MTA modules which have MTA specific email headers
    at `Sisimai::Order::Email->headers` method.

v4.24.1
--------------------------------------------------------------------------------
- release: "Wed, 14 Nov 2018 11:09:44 +0900 (JST)"
- version: "4.24.1"
- changes:
  - Fix bug in `Sisimai::RFC3464` module: scan method unintentionally detects
    non-bounce mail as a bounce #296. Thanks to @whity.
  - Remove unused method `Sisimai::DateTime->o2d()` to avoid test failure with
    Perl 5.16.2 on NetBSD #297. Thanks to Nigel Horne and CPAN Testers.
  - Build test with Perl 5.28 on Travis CI.

v4.24.0
--------------------------------------------------------------------------------
- release: "Thu,  1 Nov 2018 18:00:00 +0900 (JST)"
- version: "4.24.0"
- changes:
  - Variable improvement (remove redundant substitution)
  - Remove `Sisimai::RFC2606` (Unused module)
  - MIME decoding improvement (Import Pull-Request from sisimai/rb-Sisimai#131)
    - Implement `Sisimai::MIME->makeflat`
    - Implement `Sisimai::MIME->breaksup`
    - Call `Sisimai::MIME->makeflat()` at `Sisimai::Message::Email->parse()`
    - Other related updates in `Sisimai::Bite::Email::*`
  - Tiny improvement in `Sisimai::String->to_plain()` method.
  - Update "blocked" error message patterns for iCloud.
    - `A client IP address has no PTR record`
    - `Invalid HELO/EHLO name`

v4.23.0
--------------------------------------------------------------------------------
- release: "Fri, 31 Aug 2018 20:18:35 +0900 (JST)"
- version: "4.23.0"
- changes:
  - #195 Implement `Sisimai::Mail::Memory` class for reading bounce messages
    from memory(variable).
  - Update regular expression pattern in `Sisimai::Bite::Email::Office365` for
    detecting failure on SMTP RCPT.
  - Fix #288, test fails when localtime and gmtime differs. Thanks to @guimard.
  - Follow up Pull-Req #289 (issue #288): Some test code have been loosened for
    UTC+13(Pacific/Tongatapu), UTC+14(Pacific/Kiritimati).
  - #290 Less function calls: redundant `length` and `require` function calls
    have been removed.
  - #291 Fix typo in POD of `Sisimai::Data`. Thanks to @racke.

v4.22.7
--------------------------------------------------------------------------------
- release: "Mon, 16 Jul 2018 13:02:54 +0900 (JST)"
- version: "4.22.7"
- changes:
  - Register D.S.N. `4.4.312` and `5.4.312` on Office 365 as "networkerror".
  - Fix error message pattern in `Sisimai::Reason::SecurityError`.
  - Fix code to get the original Message-Id field which continued to the next
    line. Thanks to Andreas Mock.
  - Update error message pattern in `Sisimai::Reason::SpamDetected`.
  - Add 15 sample emails for Postfix, Outlook and others.
  - Add 3 sample emails for `Sisimai::RFC3464`.
  - Add 2 sample vacation emails for `Sisimai::RFC3834`.

v4.22.6
--------------------------------------------------------------------------------
- release: "Wed, 23 May 2018 20:00:00 +0900 (JST)"
- version: "4.22.6"
- changes:
  - #271 Most `Module::Load::load` have been replaced with `require`.
  - #272 Fix bug in `Sisimai::MIME->qprintd()`.
  - #273 Error message pattern defined in `Sisimai::Reason::Filtered` has been
    replaced with fixed strings.
  - #274 Fix many spelling errors in some Pods. Thanks to @guimard.
  - #275 Remove sample email files listed in sisimai/set-of-emails#6 to clarify
    copyrights for libsisimai-perl package on Debian. Thanks to @guimard.
  - The value of "softbounce" in the parsed results is always "1" when a reason
    is "undefined" or "onhold".
  - #278 Less regular expression in each class of `Sisimai::Bite::Email`.
  - #279 Cool logo for "set-of-emails". Thanks to @batarian71.
  - #281 Implement `Sisimai::Rhost::KDDI` for detecting a bounce reason of au
    via `msmx.au.com` or `lsean.ezweb.ne.jp`. Thanks to @kokubumotohiro.
  - #282 Update sample emails and codes for getting error messages in a bounced
    email on Oath(Yahoo!).
  - Add many sample emails for "notaccept" and "rejected".

v4.22.5
--------------------------------------------------------------------------------
- release: "Fri, 30 Mar 2018 12:29:16 +0900 (JST)"
- version: "4.22.5"
- changes:
  - #260 The order for loading MTA modules improvement.
  - #261 "make test" now passes on Windows. Thanks to @charsbar.
  - Sample emails in set-of-emails/ which are not owned by Sisimai project have
    been removed.
  - Update error message patterns in `Sisimai::Reason::Expired`.
  - Many error message patterns in Sisimai::Reason have been converted to fixed
    strings #266 #268.
  - #267, #269: Use `rindex()` function instead of `index()` function.
  - #232, #270, Pre-Updates for au.com, the new domain of EZweb announced at
    http://news.kddi.com/kddi/corporate/newsrelease/2017/08/22/2637.html

v4.22.4
--------------------------------------------------------------------------------
- release: "Wed, 14 Feb 2018 10:44:00 +0900 (JST)"
- version: "4.22.4"
- changes:
  - Issue #253, Add status code 4.7.25(RFC-7372) as "blocked".
  - Pull-Request #254, Remove unused method: `Sisimai::Bite::Email->pattern()`
    and the same methods defined in each child class.
  - Obsoleted method `Sisimai::Address->parse()` has been removed.
  - The following performance improvements makes 1.34 times faster.
    - Less regular expression #255. Thanks to @xtetsuji.
    - The following Pull-Requests have been imported from rb-Sisimai.
      - sisimai/rb-Sisimai#105
      - sisimai/rb-Sisimai#107
      - sisimai/rb-Sisimai#108
    - Replace `$v =~ /\A...\z/` with `$v eq '...'`
    - Replace `$v =~ /\A.../` with `index($v, '...') == 0`
    - Replace `$v =~ /.../` with `index($v, '...') > -1`
    - Replace `$v =~ /.\z/` with `substr($v, -1, 1) eq '.'`
    - #258 Remove `/i` modifier from each regular expression as possible and
      call `lc()` function before calling `Sisimai::Reason::*->match` method.
    - Import Pull-Request sisimai/rb-Sisimai#111, Loop improvement.
  - #251 Declaration of the version has been changed: use version;

v4.22.3
--------------------------------------------------------------------------------
- release: "Tue, 26 Dec 2017 09:22:22 +0900 (JST)"
- version: "4.22.3"
- changes:
  - Merge Pull-Request #238, Fix some typos in POD. Thanks to @brewt.
  - Add set-of-emails/json/json-amazonses-06.json as a sample JSON object from
    sisimai/rb-Sisimai#88.
  - Merge Pull-Request #239, Add bounce message patterns in MailboxFull.pm and
    Blocked.pm for laposte.net and orange.fr. Thanks to @Quickeneen.
  - Fix code to avoid warning message "Use of uninitialized value in length" at
    the following modules on only Perl 5.10.1:
    - `Sisimai::Bite::Email::GSuite`
    - `Sisimai::Message::Email`
    - `Sisimai::Address`
  - Merge Pull-Request #244 at issue #243 for following up pull-request #239,
    more support for Orange and La Poste. Thanks to @Quickeneen.
  - Merge Pull-Request #245: update error message patterns of SFR and Free.fr.
  - Merge Pull-Request #246: error message patterns have been improved on Exim.
  - Fix bug in regular expression at `Sisimai::Reason::HostUnknown`.
  - Merge Pull-Request #247, Add 100+ error message patterns into the following
    reason classes: Blocked, Expired, Filtered, HostUnknown, PolicyViolation,
    MailboxFull, NetworkError, NoRelaying, Rejected, SpamDetected, SystemError,
    Suspend, TooManyConn, and UserUnknown.
  - Merge Pull-Request #248, code improvement at `Sisimai::Data->make()` method
    to remove string like `"550-5.1.1"` from the beginning of each line in an
    error message for to be matched exactly with regular expression patterns in
    `Sisimai::Reason::*`.
  - Merge Pull-Request #248, `Sisimai::Rhost::ExchangeOnline` improved.
  - Implement new MTA module: `Sisimai::Bite::Email::FML` to parse bounce mails
    generated by fml mailing list server/manager.

v4.22.2
--------------------------------------------------------------------------------
- release: "Fri, 13 Oct 2017 11:33:00 +0900 (JST)
- version: "4.22.2"
- changes:
  - Code improvements in `Sisimai::Reason::UserUnknown`, and some MTA modules
    in `Sisimai::Bite::Email`.
  - Support parsing JSON object retrieved from SendGrid Event Webhooks #211.
  - Support "event": "spamreport" via Feedback Loop on SendGrid Event Webhooks.
  - Implement `Sisimai::Address->is_undisclosed` method.
  - Implement `Sisimai::Rhost::GoDaddy` to get a correct reason at parsing
    bounce mails from GoDaddy (reported at issue #236). Thanks to @ViktorNacht.
  - Remove obsoleted classes and methods:
    - `Sisimai::MTA`
    - `Sisimai::MSP`
    - `Sisimai::CED`
    - `Sisimai::Address->parse`

v4.22.1
--------------------------------------------------------------------------------
- release: "Tue, 29 Aug 2017 17:25:22 +0900 (JST)"
- version: "4.22.1"
- changes:
  - `Sisimai::Address` was born again to resolve issue #227
    - Implement new email address parser method: `find()`
    - Implement new constructor: `make()`
    - Implement new writable accessors: `lname()` and `comment()`
    - `parse()` method was marked as obsoleted
  - Build test with Perl 5.26 on Travis-CI.

v4.22.0
--------------------------------------------------------------------------------
- release: "Tue, 22 Aug 2017 18:25:55 +0900 (JST)"
- version: "4.22.0"
- changes:
  - #215 and Pull-Request #225, bounce reason: "securityerror" has been divided
    into the following three reasons:
    - **securityerror**
    - **virusdetected**
    - **policyviolation**
  - Sisimai now works on Perl 5.26.0
  - issue #226 All the MTA modules have been moved to `Sisimai::Bite::*` and
    old MTA/MSP modules:`Sisimai::MTA`, `Sisimai::MSP`, `Sisimai::CED`, and all
    of the methods in these classes have been marked as obsoleted.
  - Issue #227 Experimental implementation: `Sisimai::Address->find()` as born
    again parser method for email addresses. Thanks to @SteveTheTechie.

v4.21.1
--------------------------------------------------------------------------------
- release: "Mon, 29 May 2017 14:22:22 +0900 (JST)"
- version: "4.21.1"
- changes:
  - Improved error message patterns to resolve issue #221, Thanks to @racke.
  - Add `mta-exim-30.eml` as a sample email in set-of-emails/ directory.
  - Changes file has been renamed to **ChangeLog.md** and converted to Markdown
    format.
  - Pull-Request #223, Improved code to detect error messages related to DNS at
    G Suite.
  - Improved code to detect RFC7505 (NullMX) error: sisimai/set-of-emails#4.
  - Code improvements for checking and decoding irregular MIME encoded strings
    at is_mimeencoded and mimedecode methods in `Sisimai::MIME` class reported
    at sisimai/rb-Sisimai#75 from @winebarrel.
  - Add unit test codes to test all the changes at sisimai/rb-Sisimai#75.

v4.21.0 - Support G Suite
--------------------------------------------------------------------------------
- release: "Mon, 10 Apr 2017 12:17:22 +0900 (JST)"
- version: "4.21.0"
- changes:
  - Experimental implementation: new MTA module `Sisimai::MSP::US::GSuite` for
    parsing a bounce mail returned from G Suite.
    Thanks to @racke at issue #218.
  - Improved `Sisimai::SMTP::Status->find()` method. The method checks whether
    a found value as D.S.N. is IPv4 address or not.
  - Improved code for getting error messages, D.S.N. values, and SMTP reply
    codes in `Sisimai::MTA::Postfix->scan()` method.
  - Issue #212, `Sisimai->make()` and `Sisimai::Message->new()` methods check
    the value of a `field` argument more strictly.
  - Fix some typos in method comments: Import pull-request #69 at Ruby version
    of Sisimai, https://github.com/sisimai/rb-Sisimai/pull/69. Thanks to @koic.
  - Issue #217: Fix some macros in Makefile to get cpanm. Thanks to @sgroef.

v4.20.2
--------------------------------------------------------------------------------
- release: "Sat, 11 Mar 2017 16:32:48 +0900 (JST)"
- version: "4.20.2"
- changes:
  - Pull-Request #207 Add some error message patterns for a bounce message from
    Amazon SES SMTP endpoint.
  - Register sample email "rfc3834-06.eml" based on an email that is uploaded
    from @rdeavila at https://github.com/sisimai/rb-Sisimai/issues/65 to test a
    vacation message.
  - Improvements of code for the callback feature: Add a new argument `field`
    in `Sisimai->make()` to pass email header names being captured and referred
    at `Sisimai::Message::Email` class.

v4.20.1
--------------------------------------------------------------------------------
- release: "Sat, 31 Dec 2016 22:02:22 +0900 (JST)"
- version: "4.20.1"
- changes:
  - Nothing changed. Follow the fixed version of rb-Sisimai(JRuby).

v4.20.0 - Support Bounce Ojbect (JSON)
--------------------------------------------------------------------------------
- release: "Sat, 31 Dec 2016 13:36:22 +0900 (JST)"
- version: "4.20.0"
- changes:
  - Issue #199 Experimental implementation: New MTA modules for 2 Cloud Email
    Deliveries. These modules can parse JSON formatted bounce objects and can
    convert to Sisimai::Data object.
    - `Sisimai::CED::US::AmazonSES`
    - `Sisimai::CED::US::SendGrid`
  - Format of the value of `smtpagent` in the parsed result has been changed.
    It includes the category name of MTA/MSP modules like `MTA::Sendmail`,
    `MTA::Postfix`, and `MSP::US::SendGrid`: issue #200.
  - #202 The domain part of a dummy email address defined in `Sisimai::Address`
    has been changed: `dummy-domain.invalid` => **`libsisimai.org.invalid`**;
  - `Sisimai::SMTP->is_softbounce()` method has been deleted.

v4.19.0 - Callback Feature
--------------------------------------------------------------------------------
- release: "Tue, 18 Oct 2016 14:13:22 +0900 (JST)"
- version: "4.19.0"
- changes:
  - Remove utf8 flag from JSON string returned from at `Sisimai->dump` method.
  - Implement a callback feature at `Sisimai->make()` and `Sisimai->dump()`
    methods. More imformation about the feature are available at the following
    pages:
    - https://libsisimai.org/en/usage#callback
    - https://libsisimai.org/ja/usage#callback
  - Implement `Sisimai->match()` method: issue #173.
  - Minor bug fix in `Sisimai::MSP::US::AmazonSES->scan()` method.

v4.18.1
--------------------------------------------------------------------------------
- release: "Sun, 11 Sep 2016 20:05:20 +0900 (JST)"
- version: "4.18.1"
- changes:
  - Fix bug in `Sisimai::MIME->qprintd()` method reported at issue #192.
  - Import sisimai/rb-Sisimai@fb45a47, MIME decoding improvements.
  - Issue #194, fix bug in `Sisimai::Mail->new` called from `Sisimai->dump`.
    It didn't work properly when email data read from STDIN.
  - `Sisimai->dump()` and `Sisimai->make()` methods die when the number of
    arguments is neither 1 nor 3.
  - Implement `Sisimai::String->to_plain()` for converting from HTML message to
    plain text before parsing, issue #8.
  - Remove `Sisimai::String->to_regexp()` method, use `qr/\Q...\E/` instead.

v4.18.0 - Improvements for Microsoft Exchange Servers
--------------------------------------------------------------------------------
- release: "Mon, 22 Aug 2016 20:40:55 +0900 (JST)"
- version: "4.18.0"
- changes:
  - Issue #189, Soft bounce improvement. Thanks to @Quickeneen.
  - Pull-Request #190, `Sisimai::SMTP->is_softbounce()` method has been marked
    as obsoleted. Use `Sisimai::SMTP::Error->soft_or_hard()` method instead.
  - Issue #185, Sisimai works on Perl 5.24.
  - `Sisimai::MTA::Exchange` has been renamed to `Sisimai::MTA::Exchange2003`.
  - Implement new MTA module `Sisimai::MTA::Exchange2007`.

v4.17.2
--------------------------------------------------------------------------------
- release: "Tue, 26 Jul 2016 21:00:17 +0900 (JST)"
- version: "4.17.2"
- changes:
  - Issue #174, Implement `Sisimai::Rhost::ExchangeOnline` module to parse a
    bounce mail from on-premises Exchange 2013 and Office 365.
  - The reason of status code: `4.4.5` is `systemfull`.
  - Issue #181, Fixed minor bug on OpenBSD.
  - Pull-Request #185: Code improvement at `Sisimai::MSP::US::Office365`.
  - Pull-Request #188: Code improvement at `Sisimai::MIME`.
    Thanks to @jonjensen.

v4.17.1
--------------------------------------------------------------------------------
- release: "Wed, 30 Mar 2016 14:00:22 +0900 (JST)"
- version: "4.17.1"
- changes:
  - Fixed issue #179 by pull-request #180, a variable in Sisimai/MTA/Exim.pm is
    not quoted before passing to `qr//` operator. Thanks to @dzolnierz.

v4.17.0 - New Error Reason "syntaxerror"
--------------------------------------------------------------------------------
- release: "Wed, 16 Mar 2016 12:22:44 +0900 (JST)"
- version: "4.17.0"
- changes:
  - Implement new reason **syntaxerror**. Sisimai will set **syntaxerror** to
    the raeson when the value of `replycode` begins with "50" such as 502, 503,
    or 504. issue #147.
  - Implement `description()` method at each file in `Sisimai/Reason` directory
    at issue #166.
  - Implement `Sisimai->reason()` method for getting the list of reasons Sisimai
    can detect and its description: issue #168.
  - Remove unused method `Sisimai::Reason->match()`, issue #169.
  - Remove unused methods in `Sisimai::MSP` and `Sisimai::MTA`, issue #136.
  - Remove unused module `Sisimai::ISO3166`, issue #137.
  - Remove unused module `Sisimai::RFC5321` and `Sisimai::RFC3463`, issue #131.
  - Some class methods of `Sisimai::Address` allow the folowing local part as
    an email address:
    - `postmaster`
    - `mailer-daemon`
  - `Sisimai::RFC5322->is_mailerdaemon()` method returns `1` when the argument
    includes `postmaster`.
  - Merge pull-request #172, new method `Sisimai::RFC5322->weedout()` and code
    improvements in all the MTA/MSP modules.

v4.16.0 - New Error Reason "delivered"
--------------------------------------------------------------------------------
- release: "Thu, 18 Feb 2016 13:49:01 +0900 (JST)"
- version: "4.16.0"
- changes:
  - Implement new reason "**delivered**". Sisimai set `delivered` to the reason
    when the value of `Status:` field in a bounce message begins with `2`. This
    feature is optional and is not enabled by default. issue #155.
  - Implement new method `Sisimai->engine()`. The method returns the list of MTA
    and MSP module list implemented in Sisimai.

v4.15.0
--------------------------------------------------------------------------------
- release: "Sat, 13 Feb 2016 12:40:15 +0900 (JST)"
- version: "4.15.0"
- changes:
  - Implement new MSP module `Sisimai::MSP::US::AmazonWorkMail` at pull-request
    #162. The module parse bounce mails via Amazon WorkMail.
  - Implement new MSP module `Sisimai::MSP::US::Office365` at pull-request #164.
    The module parse bounce mails via Microsoft Office 365.
  - Tiny code improvements: back port from the Ruby version of Sisimai.

v4.14.2
--------------------------------------------------------------------------------
- release: "Wed,  3 Feb 2016 12:26:19 +0900 (JST)"
- version: "4.14.2"
- changes:
  - Issue #154 Fix bug: remove CR(`\r`) at the end of string in some properties
    of `Sisimai::Data` before calling the constructor. Thanks to M Miyamoto.
  - Issue #151 fix bug that the value of foled `Message-Id` field could not be
    found at pull-request #157. Thanks to @0xcdcdcdcd.
  - Fix bug in `Sisimai::MSP::RU::Yandex`: getting a pseudo delivery status.
  - Implement `Sisimai::String->to_regexp()` method to fix bug in code to build
    regular expression reported at pull-request #160, Thanks to @negachov.
  - Improved message pattern of `Sisimai::Reason::SpamDetected`.
  - Issue #158, bug fix for substituting the value of `lhost` and `rhost`.

v4.14.1 - Sample Emails Moved To "set-of-emails" Repository
--------------------------------------------------------------------------------
- release: "Sat, 26 Dec 2015 20:00:00 +0900 (JST)"
- version: "4.14.1"
- changes:
  - eg/ directory has been renamed and sample email files have been moved to the
    project repository: https://github.com/sisimai/set-of-emails, issue #153.

v4.14.0
--------------------------------------------------------------------------------
- release: "Fri, 25 Dec 2015 11:04:14 +0900 (JST)"
- version: "4.14.0"
- changes:
  - **Repository URL was changed to https://github.com/sisimai/p5-Sisimai**
  - `Sisimai::MTA->SMTPCOMMAND()` method has been obsoleted from this version.
    Use `Sisimai::SMTP->command()` instead, issue #136.
  - `Sisimai::MTA->LONGFIELDS` and `Sisimai::MTA->RFC822HEADERS` are obsoleted.
    Use `Sisimai::RFC5322->LONGFIELDS()` and `Sisimai::RFC5322->HEADERFIELDS()`
    instead.
  - Change internal method names of `Sisimai::Message`
      - `rewrite()` begins `parse()`
      - `resolve()` begins `make()`
  - Issue #110, #122 Code for reading email files in a directory is improved
    and got faster than before: merged Pull-Request #123.
  - Fixed bug reported at issue #124: warning message: `use of uninitialized
    value in substr at` is displayed when `Sisimai::Message->resolve()` method 
    parses an UNIX mbox which begins from blank line.
  - Merged Pull-Request #125, filehandle will not be closed until EOF of each
    UNIX mbox in `Sisimai::Mail::Mbox->read()` method.
  - Merged Pull-Request #126, replace `while( <$f> )` with `do {...}` block for
    reading each email file in a directory at `Sisimai::Mail::Maildir->read()`
    method.
  - Merged Pull-Request #132, Resolve issue #127: Sisimai cannot parse a mail
    which message body is MIME encoded. Thanks to @mrwushu.
  - Issue #134, `Sisimai::RFC3463` and `Sisimai::RFC5321` have been obsoleted
    but are not removed. Use `Sisimai::SMTP::Status`, `Sisimai::SMTP::Reply`
    instead. 
  - Merged Pull-Request #138, some code blocks in `Sisimai::Message->resolve()`
    have been divided into some methods.
  - Fixed bug at issue #142, Sisimai can not parse an email that TAB or Space
    character exists at the end of each line. Thanks to M Miyamoto.
  - Fixed bug at issue #144, support date format like `Thursday, Apr 29, ...`.
  - Improved code of `Sisimai::MTA::IMailServer` for support more error message
    patterns: issue #143.
  - Issue #145 Code improvements: back port from Ruby version of Sisimai.
  - Fix bugs in regular expression to detect SMTP command in `Sisimai::MTA::X4`
    and `Sisimai::MTA::qmail` modules.

v4.13.1 - Two White Cats
--------------------------------------------------------------------------------
- release: "Tue, 17 Nov 2015 14:13:10 +0900 (JST)"
- version: "4.13.1"
- changes:
  - Issue #95, Add some sample emails for `Sisimai::MTA::Exim`.
  - Improved code `Sisimai::MTA::Exim` to get the reason and the SMTP command
    from LMTP error message.
  - Improved error message patterns at the following modules:
      - `Sisimai::Reason::UserUnknown`
      - `Sisimai::Reason::Rejected`
      - `Sisimai::Reason::Blocked`
  - Issue #96, Improved `Sisimai::MTA::Exim` for parsing "Frozen message".
  - Issue #101, Improved code for getting DSN value in `Sisimai::MTA::Exim`.
  - Issue #107, Improved slow regular expression in `Sisimai::MSP::JP::EZweb`.
  - Issue #114 (MTA Order Optimization) issue #116 (Performance tunings), and
    issue #118 (Regular expression across the MTA modules) are merged. These
    improvements that were taught from two white cats in my dream on Nov. 7,
    and have made Sisimai 1.15 times faster. Thanks to sensible white cats.

v4.13.0 - To Be Semantic Versioning
--------------------------------------------------------------------------------
- release: "Thu,  5 Nov 2015 16:11:12 +0900 (JST)"
- version: "4.13.0"
- changes:
  - **Issue #85, Use Semantic Versioning from this release. New version number
    is v4.13.0 <= v4.1.30.**
  - Issue #84, Experimental implementation: New module `Sisimai::MTA::X5` and
    added a sample email(x5-01.eml) for the module. Thanks to Masayoshi.M .
  - Issue #86, Removed unused `version()` method from the following modules:
    `Sisimai::RFC3464`, `Sisimai::RFC3834`, `Sisimai::ARF`, `Sisimai::MTA::*`,
    and `Sisimai::MSP::*::*`.
  - Issue #88, #89: fixed `Sisimai::MTA::Notes` and added notes-04.eml.
  - Issue #90, #91: fixed code around `Sisimai::Data->alias()`.
  - Improved codes of `Sisimai::MTA::*`, `Sisimai::MSP::*`, `Sisimai::RFC3464`
    and `Sisimai::ARF` as a precaution against serious bug reported on #89.
  - Improved codes and serious bug fix for issue #89 have made Sisimai 1.10
    times faster than before.
  - Issue #92, All the methods have YARD format comment.
  - Issue #93, #94: Fixed bug and improved code for getting alias address and
    setting the error reason in `Sisimai::MTA::Exim`.

v4.1.29
--------------------------------------------------------------------------------
- release: "Tue,  6 Oct 2015 10:55:00 +0900 (JST)"
- version: "4.1.29"
- changes:
  - Issue #83, New MTA module implemented as `Sisimai::MSP::US::ReceivingSES`.
    This module parse bounce mails from Amazon SES(Receiving).
  - Improved code for getting and setting the value of `Status:` field.
  - Improved document in `Sisimai::Data` and `Sisimai::Reason`, imported from
    web site: https://libsisimai.org/ .
  - Added new sample email rfc3834-03.eml to test code for `Sisimai::RFC3834`.
  - Added new sample emails: sendmail-26,27,28,29,30,31,32.eml. 

v4.1.28 - HAPPY 1ST BIRTHDAY
--------------------------------------------------------------------------------
- release: "Sun, 16 Aug 2015 14:50:20 +0900 (JST)"
- version: "4.1.28"
- changes:
  - **Happy 1st Birthday To Sisimai !!**
  - Experimental implementation about issue #76: New module `Sisimai::RF3834`
    is for detecting auto replied message and decides a reason as `vacation`.
  - Fixed bug in `Sisimai::Message` for setting the order of MTA, MSP modules.
  - Issue #70, Implemented code for using user defined MTA module and added
    `Sisimai::MTA::UserDefined` as a sample.
  - Issue #78, Implement new accessor `->softbounce` in `Sisimai::Data` object.

v4.1.27 - Sisimai->dump() Method
--------------------------------------------------------------------------------
- release: "Fri, 17 Jul 2015 11:45:05 +0900 (JST)"
- version: "4.1.27"
- changes:
  - New method implemented: `Sisimai->dump('/path/to/mbox')` return parsed data
    as JSON string.
  - Updated error message patterns in the following classes:
    - `Sisimai::Reason::NoRelaying`
    - `Sisimai::Reason::TooManyConn`
    - `Sisimai::Reason::Blocked`
  - Fixed code in `Sisimai::Reason::MesgTooBig`. Error reason of bounce message
    that the value of `Status` field is 5.2.3 will be set as `exceedlimit`.
  - Fixed code to get the value of Message-Id header in the original message at
    `Sisimai::Data` class.
  - Sisimai reports the bounce reason as `onhold` when `Sisimail::Reason->get`
    method did not decide the reason and the value of `diagnosticcode` is not
    empty.
  - Issue #74 is that reported at CPAN Testers Report might be fixed.
  - Issue #75, Improved code for parsing 2-digit year value in a `Date:` header
    at Sisimai::DateTime class.
  - Test codes for MTA modules: `Sisimai::MTA`, `Sisimai::MSP`, `Sisimai::ARF`,
    and `Sisimai::RFC3464` have been integrated and improved.

v4.1.26 - New Error Reason "toomanyconn"`
--------------------------------------------------------------------------------
- release: "Sat,  4 Jul 2015 11:34:44 +0900 (JST)"
- version: "4.1.26"
- changes:
  - Module name changed from `Sisimai::Reason::RelayingDenied` to "NoRelaying".
  - Registered new error reason "TooManyConn". This reason is bounced due to 
    that too many connections or exceeded connection rate limit.
  - Included many error messages listed in SendGrid "Deliverability Center":
    "https://sendgrid.com/deliverabilitycenter/" as a regular expression at 
    Sisimai::Reason::*. Thanks to Bogdan B. and SendGrid.
  - Experimental implementation: `Sisimai::Reason->match()` is for detecting a
    bounce reason from given text as an error message.
  - Experimental impelmentation about issue #61: New MTA module implemented
    as `Sisimai::MTA::ApacheJames`. The module is for parsing bounce emails 
    which are generated by Apache James/Java Apache Mail Enterprise Server.
    Thanks to John Aldrich Quan.
  - Issue #72, Support SMTP reply code in `Sisimai::Data` object.
  - Fixed code: Add "SystemFull" reason into `Sisimai::Reason->anotherone()`.
  - Improved regular expression in `Sisimai::MSP::US::Google`.

v4.1.25 - Reason Name "nospam" Changed To "spamdetected"
--------------------------------------------------------------------------------
- release: "Mon, 22 Jun 2015 11:45:29 +0900 (JST)"
- version: "4.1.25"
- changes:
  - **Reason name has been changed from "NoSpam" to "SpamDetected".**
  - Package name has been changed from `Sisimai::Time` to `Sisimai::DateTime`.
  - Implemnet `Sisimai::Time` again as a child class of `Time::Piece`.
  - The class of "timestamp" is now `Sisimai::Time` in `Sisimai::Data` object.
  - Implement `Sisimai::Reason::HasMoved`.
  - 2 emails bounced due to "expired" reason have been added as a sample for
    issue #50.
  - Fix bug in `Sisimai::MTA::MailMarshalSMTP` for a bounce mail which have no
    boundary strings.
  - Fix bug in `Sisimai::MTA::Exim` for setting an error reason decided by SMTP
    MAIL command.
  - Improved regular expression in `Sisimai::RFC3464`.
  - Update `Sisimai::MDA`, add an error message pattern defined in dovecot 1.2,
    dovecot/src/plugins/quota/quota.c.
  - Update message patterns at SpamDetected, SystemError, Blocked, Filtered,
    RelayingDenied, NetworkError, MesgTooBig, MailboxFull, SecurityError, 
    UserUnknown and Suspend.
  - Fix code for detecting MIME encoded string in `Sisimai::MIME`.
  - Implement `TO_JSON` method in `Sisimai::Address` for JSON module.
  - Add test code for sample emails in CRLF.
  - Add sample emails which is an IDN email.
  - Add sample emails which could not be parsed yet into eg/cannot-parse-yet/
    directory and implement test code.
  - Add sample emails which reason is "undefined" into eg/reason-is-undefined
    directory and implement test code.

v4.1.24
--------------------------------------------------------------------------------
- release: "Mon, 11 Jun 2015 22:20:59 +0900 (JST)"
- version: "4.1.24"
- changes:
  - Improved fallback code in `Sisimai::RFC3464`.
  - Add message patterns at NoSpam and HostUnknown in Sisimai/Reason.

v4.1.23
--------------------------------------------------------------------------------
- release: "Thu, 11 Jun 2015 13:20:59 +0900 (JST)"
- version: "4.1.23"
- changes:
  - Sisimai works on Perl 5.22.0.
  - New MTA module `Sisimai::MTA::X4` for qmail clone MTAs.
  - Performance tuning, Sisimai is now 1.39 times faster than before.
  - Improved code in Sisimai/Message.pm: 1.62 times faster than before.
  - Bug fix in `Sisimai::MSP::JP::EZweb` and `Sisimai::MSP::JP::KDDI`.
  - Support "2015-04-29 01:23:45" date format in `Sisimai::Time`.
  - Support the value of Diagnostic-Code without the value of "diagnostic-type"
    field in `Sisimai::RFC3464`.
  - Emails in https://github.com/sendgrid/go-gmime/tree/master/gmime/fixtures
    and some emails have been added as a sample in eg/ directory.
  - Add message patterns at NoSpam, MailboxFull, RelayingDenied, UserUnknown, 
    Blocked, Filtered, SecurityError, Expired, HostUnknown, and NetworkError
    in Sisimai/Reason/ directory.
  - Fix bug in `Sisimai::Data` for calling `Sisimai::Time->parse()` method.
  - `Sisimai::MTA::IMailServer` and `Sisimai::MTA::InterScanMSS` updated.
  - Implement fallback code in `Sisimai::RFC3464`: parse entire message body to
    get a recipient address and error messages. The value of the `smtpagent`
    parsed by this code is `RFC3464::Fallback`.

v4.1.22
--------------------------------------------------------------------------------
- release: "Thu, 28 May 2015 14:20:59 +0900 (JST)"
- version: "4.1.22"
- changes:
  - Merged pull request #59 (Support for Microsoft custom ARF format) at 
    https://github.com/azumakuniyuki/p5-Sisimai/pull/59 . Thanks to @jleroy.
  - Issue #60: Add `Time::Piece` and `Module::Load` to ./cpanfile.
    Thanks to @kkdYodoKazahaya
  - Update `Sisimai::ARF` for parsing Amazon SES Complaints bounces.

v4.1.21
--------------------------------------------------------------------------------
- release: "Tue, 21 Apr 2015 14:20:59 +0900 (JST)"
- version: "4.1.21"
- changes:
  - Update regular expressions of each error message pattern at Sisimai/Reason/
    direcotry: NoSpam, Suspend, Blocked, UserUnknown, Expired, NetworkError,
    MailboxFull and MesgTooBig.
  - Fix bug for setting the value of SMTP command at `Sisimai::Data`.
  - Update regular expression of "expired" in `Sisimai::MTA::Exim`.
  - Add three sample emails for `make test` in eg/ directory.

v4.1.20
--------------------------------------------------------------------------------
- release: "Thu,  9 Apr 2015 14:20:59 +0900 (JST)"
- version: "4.1.20"
- changes:
  - Update regular expressions of each error message pattern at SystemError.pm, 
    MesgTooBig.pm and NoSpam.pm in Sisimai/Reason.
  - Add two sample emails for `make test` in eg/ directory.

v4.1.19 - New Error Reason "nospam"
--------------------------------------------------------------------------------
- release: "Mon,  6 Apr 2015 14:20:59 +0900 (JST)"
- version: "4.1.19"
- changes:
  - Update regular expressions of each error message pattern at Rejected.pm,
    Mailboxfull.pm, MesgTooBig.pm, and UserUnknown.pm in Sisimai/Reason.
  - **New error reason "nospam" implemented.**
  - Some message patterns have moved from `Sisimai::Reason::SecurityError` to
    `Sisimai::Reason::NoSpam` module.

v4.1.18 - New Repository Name "p5-Sisimai"
--------------------------------------------------------------------------------
- release: "Fri, 27 Mar 2015 12:59:07 +0900 (JST)"
- version: "4.1.18"
- changes:
  - **Repository name on github has been changed to p5-Sisimai.**
  - Fixed code around regular expressions of "mailboxfull" and "expired" in MTA
    modules: `Sisimai::MTA::qmail` and `Sisimai::MTA::Exim`. Thanks to @m-walk
    at issue #57.
  - Update regular expressions of error message pattern at SecurityError.pm
    and Blocked.pm in Sisimai/Reason.

v4.1.17
--------------------------------------------------------------------------------
- release: "Mon,  2 Mar 2015 16:01:20 +0900 (JST)"
- version: "4.1.17"
- changes:
  - Improved regular expressions of networkerror, expired and related code in
    `Sisimai::MTA::qmail`. Thanks to @m-walk at issue #56.

v4.1.16
--------------------------------------------------------------------------------
- release: "Wed, 18 Feb 2015 16:01:20 +0900 (JST)"
- version: "4.1.16"
- changes:
  - Add bounce emails as a sample from Postfix 3.0.0.
  - Improved code for reading mail data from STDIN at `Sisimai::Mail`.
  - Try to load `YAML::Syck` module instead of YAML module when string `"yaml"`
    is specified in the argument of `Sisimai::Data->dump()` method.

v4.1.15
--------------------------------------------------------------------------------
- release: "Wed, 11 Feb 2015 13:59:59 +0900 (JST)"`
- version: "4.1.15"
- changes:
  - Improved code for detecting abuse message "opt-out" in `Sisimai::ARF`.
  - Minor improvements in `Sisimai::MTA::Postfix`.

v4.1.14 - Accessors Of Sisimai::Mail Changed
--------------------------------------------------------------------------------
- release: "Fri,  6 Feb 2015 13:29:59 +0900 (JST)"
- version: "4.1.14"
- changes:
  - Update `Sisimai::MSP::US::Outlook` for delayed message.
  - Implement new module: `Sisimai::Mail::STDIN` for reading email data from
    standard-in.
  - **Changed accessor names in `Sisimai::Mail::Mbox`, `Sisimai::Mail::Maildir`
    modules: `name` to `file`, `files` to `inodes`.**
  - **Accessor `path` always return the path to a mailbox or path to each mail
    file in Maildir/ at `Sisimai::Mail::Mbox` and `Sisimai::Mail::Maildir`.**
  - Implement new accessor `dir`, it returns the path to directory of given
    argument in `Sisimai::Mail::Mbox` and `Sisimai::Mail::Maildir`.

v4.1.13 - Sisimai::Reason->index
--------------------------------------------------------------------------------
- release: "Tue, 27 Jan 2015 15:00:55 +0900 (JST)"
- version: "4.1.13"
- changes:
  - Fixed bug in test code for `Sisimai::DATA::YAML`. Thanks to CPAN Testers
    Reports.
  - Implement new method `Sisimai::Reason->index()`, returns the list of bounce
    reasons.

v4.1.12 - New Error Reason "networkerror"
--------------------------------------------------------------------------------
- release: "Sat, 24 Jan 2015 15:00:59 +0900 (JST)"
- version: "4.1.12"
- changes:
  - Update sample code in POD at `Sisimai::RFC5322` and test codes (RT#101436,
    Issue #41, See https://rt.cpan.org/Ticket/Display.html?id=101436). Thanks
    to Mark Stosberg.
  - **Changed accessor name: `data` to `path` in `Sisimai::Mail`.**
  - Space character will be inserted after ":" in `Sisimai::Data::JSON`.
  - Improved regular expression for getting the value of email header at each
    MTA module.
  - Message patterns related to DNS or network error have been moved to new
    module: `Sisimai::Reason::NetworkError`.
  - **New error reason "networkerror": the value of reason for bounce messages
    returned due to network related errors will be set as the reason.**
  - **Sisimai does not rely on `Try::Tiny` module from this version.**

v4.1.11 - Performance Improvements
--------------------------------------------------------------------------------
- release: "Thu, 15 Jan 2015 15:01:59 +0900 (JST)"
- version: "4.1.11"
- changes:
  - Improved code in Sisimai/Mail/Mbox.pm: using `substr()` function instead of
    a regular expression is 1.46 times faster than before.
  - Code improvement in Sisimai/Reason.pm: using `grep {}` block instead of a 
    regular expression is 133% faster than before.
  - Revert commit 0c7782cecafdc923d3c82b81a201a787611654ea for `Sisimai::Time`.
  - Improvement of pattern match in Sisimai/Message.pm is 2.27 times faster.
  - Improvement of regular expressions in each MTA module is 115% faster than
    before.

v4.1.10 - +2 MTA Modules
--------------------------------------------------------------------------------
- release: "Mon, 12 Jan 2015 17:59:35 +0900 (JST)"
- version: "4.1.10"
- changes:
  - Implement the following MTA/MSP modules:
    - `Sisimai::MSP::UK::MessageLabs` (Symantec.cloud: formerly MessageLabs)
    - `Sisimai::MSP::US::Bigfoot` (bigfoot.com)
  - Added 2 sample emails: arf05.eml, arf-06.eml and improved `Sisimai::ARF`
    from pull request #37, Thanks to @jcbf.
  - Merged pull request #38, Updated `Sisimai::US::Facebook` and DMARC forensic
    related codes, and error message patterns in Sisimai::Reason::* modules.
    Thanks to @jcbf.
  - Merged pull request #39, Updated `Sisimai::RFC3464` and message patterns in
    `Sisimai::Reason::SecurityError` and Suspended. Thanks to @jcbf.
  - Regular expression improvements in each MTA module(issue #40) is between
    122% and 800% faster than Sisimai 4.1.9.

v4.1.9  - +3 MTA Modules
--------------------------------------------------------------------------------
- release: "Wed, 31 Dec 2014 18:59:22 +0900 (JST)"
- version: "4.1.9"
- changes:
  - Implement the following MTA/MSP modules:
    - `Sisimai::MTA::X3` (Unknown MTA(3))
    - `Sisimai::MSP::DE::EinsUndEins` (1&1)
    - `Sisimai::MTA::MailMarshalSMTP` (Trustwave Secure Email Gateway: formerly
       MailMarshal SMTP)
  - Improved code for getting error message in a bounce mail from MXLogic.
  - Added 4 sample emails from pull request #32, Thanks to @jcbf.
  - Added 4 sample emails and updated error message patterns at some files in
    Sisimai/Reason directory from pull request #34, Thanks to @jcbf.
  - Improved code for getting FBL related values in `Sisimai::ARF`.

v4.1.8  - YAML is Also Supported
--------------------------------------------------------------------------------
- release: "Fri, 19 Dec 2014 17:22:59 +0900 (JST)"
- version: "4.1.8"
- changes:
  - Support new data format: YAML(optional, "YAML" module required).

v4.1.7
--------------------------------------------------------------------------------
- release: "Thu, 18 Dec 2014 23:59:59 +0900 (JST)"
- version: "4.1.7"
- changes:
  - Tiny code improvement of `Sismai::MSP::RU::Yandex`.
  - Improved code for detecting email bounce from MXLogic.
  - Add some message patterns into `Sisimai::Reason::Expired`.
  - Implement the following MTA/MSP modules:
    - `Sisimai::MSP::US::Zoho` (Zoho Mail)
    - `Sisimai::MTA::X2` (Unknown MTA(2))
  - Improved code for getting error message in a bounce mail from Zoho Mail.

v4.1.6
--------------------------------------------------------------------------------
- release: "Sun,  7 Dec 2014 22:44:36 +0900 (JST)"
- version: "4.1.6"
- changes:
  - Improved code for parsing email bounce from @nokiamail.com.
  - Implement `Sisimai::MSP::RU::Yandex` for email bounces from Yandex.Mail.

v4.1.5
--------------------------------------------------------------------------------
- release: "Fri,  5 Dec 2014 18:20:22 +0900 (JST)"
- version: "4.1.5"
- changes:
  - Fix newline of some sample emalis in `eg/` directory.

v4.1.4
--------------------------------------------------------------------------------
- release: "Thu,  4 Dec 2014 20:40:22 +0900 (JST)"
- version: "4.1.4"
- changes:
  - Improved code for checking bounce mail in `Sisimai::MTA::OpenSMTPD`.
  - Implement the following modules for Email Service Providers:
    - `Sisimai::MSP::RU::MailRu` (@mail.ru)
    - `Sisimai::MSP::DE::GMX` (GMX)

v4.1.3  - Add 5 MTA/MSP Modules
--------------------------------------------------------------------------------
- release: "Sun, 23 Nov 2014 21:22:55 +0900 (JST)"
- version: "4.1.3"
- changes:
  - Improved code for detecting error reason in `Sisimai::Reason` module.
  - Implement the following MTA/MSP modules:
    - `Sisimai::MTA::MessagingServer` (Oracle Communications Messaging Server,
      Sun Java System Messaging Server)
    - `Sisimai::MTA::X1` (Unknown MTA(1))
    - `Sisimai::MSP::US::Yahoo` (Yahoo! MAIL)
    - `Sisimai::MSP::US::Aol` (Aol Mail)
    - `Sisimai::MSP::US::Outlook` (Outlook.com)

v4.1.2  - Key Name Changed To "timestamp"
--------------------------------------------------------------------------------
- release: "Sat, 22 Nov 2014 22:22:22 +0900 (JST)"
- version: "4.1.2"
- changes:
  - Require `Time::Local` 1.19 or later for fixing issue #21, #23, and #24.
  - **Key name of time stamp has been changed from `date` to `timestamp`**.
  - Data sources and hash algorithm of token string in parsed data have been 
    changed.
  - Implement the following MTA modules:
    - `Sisimai::MTA::InterScanMSS`
      (Trend Micro InterScan Messaging Security Suite)
    - `Sisimai::MTA::SurfControl` (WebSense SurfControl)
    - `Sisimai::MTA::V5sendmail`
      (Sendmail v5 and other MTAs based on V5 Sendmail)
  - Fixed bounce reason names in `Sisimai::RFC3463`.

v4.1.1  - Support 6+ Commercial MTAs
--------------------------------------------------------------------------------
- release: "Mon, 10 Nov 2014 15:59:03 +0900 (JST)"
- version: "4.1.1"
- changes:
  - Fix tiny bug in `Sisimai::MTA::Exim`.
  - Add many sample emails into `eg/` directory.
  - Improved code for detecting connection errors at Sendmail and Courier.
  - `Sisimai::RFC3464` and `Sisimai::MTA::Exchange` imporved.
  - Implement the following MTA/MSP modules for commercial MTAs:
    - `Sisimai::MTA::Notes` (Lotus Notes)
    - `Sisimai::MTA::McAfee`
    - `Sisimai::MTA::MXLogic` (McAfee Product)
    - `Sisimai::MTA::MailFoundry`
    - `Sisimai::MTA::IMailServer` (IPSWITCHI IMail Server)
    - `Sisimai::MTA::mFILTER` (DigitalArts m-FILTER)
    - `Sisimai::MTA::Activehunter` (TransWARE Active!hunter)
  - Improved code for deciding error reason at Sendmail and qmail.

v4.1.0  - Sisimai::Group Removed Permanently
--------------------------------------------------------------------------------
- release: "Sat,  4 Oct 2014 15:09:09 +0900 (JST)"
- version: "4.1.0"
- changes:
  - Sisimai::Group::* child classes and `provider`, `category` as a property in
    the parsed data have been removed permanently.
  - Fix the newline in sample email files for `make test`.

v4.0.2  - Support Amazon SES and SendGrid
--------------------------------------------------------------------------------
- release: "Wed, 10 Sep 2014 22:45:43 +0900 (JST)"
- version: "4.0.2"
- changes:
  - Implement the following MTA/MSP modules:
    - `Sisimai::MSP::US::AmazonSES`
    - `Sisimai::MSP::US::SendGrid`
    - `Sisimai::MTA::Domino` (IBM Domino)
  - Large scale code refactoring at Sisimai::RFC3464.

v4.0.1
--------------------------------------------------------------------------------
- release: "Sun, 17 Aug 2014 23:00:00 +0900 (JST)"
- version: "4.0.1"
- changes:
  - Fixed bug for reading each email file in the Maildir given as an argument
    of `Sisimai::Mail::Maildir->read()` method.
  - Refactoring around codes to return the parsed data.
  - Implement `make()` method to get bounce data at Sisimai.pm.

v4.0.0 - the first release
--------------------------------------------------------------------------------
- release: "Sat, 16 Aug 2014 20:00:00 +0900 (JST)"
- version: "4.0.0"
- changes:
  - The first release of Sisimai.

