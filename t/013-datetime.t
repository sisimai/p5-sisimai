use strict;
no warnings 'once';
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::DateTime;
use Time::Piece;
require './t/999-values.pl';

my $Package = 'Sisimai::DateTime';
my $Methods = {
    'class'  => ['monthname', 'parse', 'abbr2tz', 'tz2second', 'second2tz'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $v = $Package; 
    my $L = {
        'false' => $Sisimai::Test::Values::False,
        'minus' => $Sisimai::Test::Values::Minus,
        'zero'  => $Sisimai::Test::Values::Zeros,
        'ctrl'  => $Sisimai::Test::Values::CTLChars,
        'esc'   => $Sisimai::Test::Values::ESCChars,
    };

    MONTH_NAME: {
        my $month = $v->monthname();
        isa_ok $month, 'ARRAY', $v.'->monthname()';
        is $month->[0], 'Jan', $v.'->monthname()->[0]';
        is $month->[6], 'Jul', $v.'->monthname()->[6]';

        $month = $v->monthname(0);
        isa_ok $month, 'ARRAY', $v.'->monthname(0)';
        is $month->[0], 'Jan', $v.'->monthname(0)->[0]';
        is $month->[9], 'Oct', $v.'->monthname(0)->[9]';

        $month = $v->monthname(1);
        isa_ok $month, 'ARRAY', $v.'->monthname(1)';
        is $month->[1], 'February', $v.'->monthname(1)->[1]';
        is $month->[8], 'September', $v.'->monthname(1)->[8]';
    }

    PARSE: {
        my $datestrings = [
            'Mon, 2 Apr 2001 04:01:03 +0900 (JST)',
            'Fri, 9 Apr 2004 04:01:03 +0000 (GMT)',
            'Thu, 5 Apr 2007 04:01:03 -0000 (UTC)',
            'Thu, 03 Mar 2010 12:46:23 +0900',
            'Thu, 17 Jun 2010 01:43:33 +0900',
            'Thu, 1 Apr 2010 20:51:58 +0900',
            'Thu, 01 Apr 2010 16:25:40 +0900',
            '27 Apr 2009 08:08:54 +0000',
            'Fri,18 Oct 2002 16:03:06 PM',
            '27 Sep 1998 00:51:27 -0400',
            'Sat, 21 Nov 1998 16:38:02 -0500 (EST)',
            'Sat, 21 Nov 1998 13:13:04 -0800 (PST)',
            '    Sat, 21 Nov 1998 15:40:24 -0600',
            'Thu, 19 Nov 98 06:53:46 +0100',
            '03 Apr 1998 09:59:35 +0200',
            '19 Mar 1998 20:55:10 +0100',
            '2010-06-18 17:17:52 +0900',
            '2010-06-18T17:17:52 +0900',
            'Foo, 03 Mar 2010 12:46:23 +0900',
            'Thu, 13 Mar 100 12:46:23 +0900',
            'Thu, 03 Mar 2001 12:46:23 -9900',
            'Thu, 03 Mar 2001 12:46:23 +9900',
            'Sat, 21 Nov 1998 13:13:04 -0800 (PST)    ',
            'Sat, 21 Nov 1998 13:13:04 -0800 (PST) JST',
            'Sat, 21 Nov 1998 13:13:04 -0800 (PST) Hoge',
            'Fri, 29 Apr 2013 02:31 +0900',
            'Sun, 29 Apr 2014 1:2:3 +0900',
            'Sun, 29 May 2014 1:2 +0900',
            '4/29/01 11:34:45 PM',
            '2014-03-26 00-01-19',
            '29-04-2017 22:22',
        ];

        my $invaliddates = [
            'Thu, 13 Cat 2000 22:22:22 +2222',
            'Thu, 17 Apr 1192 12:46:23 +0900',
            'Thu, 19 May 2600 14:51:10 +0900',
            'Thu, 22 Jun 2001 32:40:29 +0900',
            'Thu, 25 Jul 1995 00:86:00 +0900',
            'Thu, 31 Aug 2013 11:22:73 +0900',
            'Thu, 36 Sep 2009 11:22:33 +0900',
        ];

        for my $e ( @$datestrings ) {
            my $time = undef;
            my $text = $v->parse($e);
            ok length $text, '->parse('.$e.') = '.$text;

            $text =~ s/\s+[-+]\d{4}\z//;
            $time = Time::Piece->strptime($text, '%a, %d %b %Y %T');
            isa_ok $time, 'Time::Piece';
            ok $time->cdate, '->cdate = '.$time->cdate;
        }

        for my $e ( @$invaliddates ) {
            my $text = $v->parse($e);
            ok length($text || '') == 0, '->parse('.$e.') = '.($text || '');
        }

        my $e = $v->parse();
        is $e, undef, '->parse() = undef';
    }

    ABBR2TZ: {
        is $v->abbr2tz('GMT'), '+0000', 'GMT = +0000';
        is $v->abbr2tz('UTC'), '-0000', 'UTC = -0000';
        is $v->abbr2tz('JST'), '+0900', 'JST = +0900';
        is $v->abbr2tz('PDT'), '-0700', 'PDT = -0700';
        is $v->abbr2tz('MST'), '-0700', 'MST = -0700';
        is $v->abbr2tz('CDT'), '-0500', 'CDT = -0500';
        is $v->abbr2tz('EDT'), '-0400', 'EDT = -0400';
        is $v->abbr2tz('HST'), '-1000', 'HST = -1000';
        is $v->abbr2tz('UT'),  '-0000', 'UT  = -0000';
        is $v->abbr2tz(),      undef,   '""  = undef';
    }

    TIMEZONE_TO_SECOND: {
        is $v->tz2second('+0000'), 0, $v.'->tz2second(+0000)';
        is $v->tz2second('-0000'), 0, $v.'->tz2second(-0000)';
        is $v->tz2second('-0900'), -32400, $v.'->tz2second(-0900)';
        is $v->tz2second('+0900'), 32400, $v.'->tz2second(+0900)';
        is $v->tz2second('-1200'), -43200, $v.'->tz2second(-1200)';
        is $v->tz2second('+1200'), 43200, $v.'->tz2second(+1200)';
        is $v->tz2second('-1800'), undef, $v.'->tz2second(-1800)';
        is $v->tz2second('+1800'), undef, $v.'->tz2second(+1800)';
        is $v->tz2second('NULL'), undef, $v.'->tz2second(NULL)';
        is $v->tz2second, undef, $v.'->tz2second';
    }

    SECOND_TO_TIMEZONE: {
        is $v->second2tz(0), '+0000', $v.'->second2tz(0)';
        is $v->second2tz(-32400), '-0900', $v.'->second2tz(-32400)';
        is $v->second2tz(32400), '+0900', $v.'->second2tz(32400)';
        is $v->second2tz(-43200), '-1200', $v.'->second2tz(-43200)';
        is $v->second2tz(43200), '+1200', $v.'->second2tz(43200)';
        is $v->second2tz(-65535), '', $v.'->second2tz(65535)';
        is $v->second2tz(65535), '', $v.'->second2tz(65535)';
        is $v->second2tz(0e0), '+0000', $v.'->second2tz(0e0)';
        is $v->second2tz(), '+0000', $v.'->second2tz()';
    }

    IRREGULAR_CASE: {
        for my $e ( @{ $L->{'false'} }, @{ $L->{'zero'} }, @{ $L->{'esc'} }, @{ $L->{'ctrl'} } ) {
            my $r = defined $e ? sprintf("%#x", ord $e) : 'undef';
            is $v->tz2second($e), undef, '->tz2second() The value: '.$r;
        }

        for my $e ( @{ $L->{'minus'} } ) {
            is $v->tz2second($e), undef, '->tz2second() The value: '.$e;
        }
    }
}

done_testing();
