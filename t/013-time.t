use strict;
no warnings 'once';
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Time;
use Time::Piece;
require './t/999-values.pl';

my $PackageName = 'Sisimai::Time';
my $MethodNames = {
    'class' => [ 
        'to_second', 'monthname', 'hourname', 'dayofweek',
        'o2d', 'parse', 'abbr2tz', 'tz2second', 'second2tz',
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v = $PackageName; 
    my $L = {
        'false' => $Sisimai::Test::Values::FALSE,
        'minus' => $Sisimai::Test::Values::MINUS,
        'zero'  => $Sisimai::Test::Values::ZEROS,
        'ctrl'  => $Sisimai::Test::Values::CTL_CHARS,
        'esc'   => $Sisimai::Test::Values::ESC_CHARS,
    };

    TO_SECOND: {
        is $v->to_second( '1d' ), 86400, $v.' 1 Day';
        is $v->to_second( '2w' ), ( 86400 * 7 * 2 ), $v.' 2 Weeks';
        is $v->to_second( '3f' ), ( 86400 * 14 * 3 ), $v.' 3 Fortnites';
        is int $v->to_second( '4l' ), 10205771, $v.' 4 Lunar months';
        is int $v->to_second( '5q' ), 39446190, $v.' 5 Quarters';
        is int $v->to_second( '6y' ), 189341712, $v.' 6 Years';
        is int $v->to_second( '7o' ), 883594656, $v.' 7 Olympiads';
        is int $v->to_second( 'gs' ), 23, $v.' 23.14(e^p) seconds';
        is int $v->to_second( 'pm' ), 188, $v.' 3.14(PI) minutes';
        is int $v->to_second( 'eh' ), 9785, $v.' 2.718(e) hours';
        is $v->to_second(-1), 0, 'The value: -1';
        is $v->to_second( -4294967296 ), 0, ' The value: -4294967296';
    }

    IRREGULAR_CASE: {
        for my $e ( @{ $L->{'false'} }, @{ $L->{'zero'} }, @{ $L->{'esc'} }, @{ $L->{'ctrl'} } ) {
            my $r = defined $e ? sprintf( "%#x", ord $e ) : 'undef';
            is $v->to_second( $e ), 0, '->to_second The value: '.$r; 
        }

        for my $e ( @{ $L->{'minus'} } ) {
            is $v->to_second( $e ), 0, '->to_second() The value: '.$e;
        }
    }

    MONTH_NAME: {
        my $month = undef;

        $month = $v->monthname(0);
        isa_ok $month, 'ARRAY', $v.'->monthname(0)';
        is $month->[0], 'Jan', $v.'->monthname(0)->[0]';
        is $month->[9], 'Oct', $v.'->monthname(0)->[9]';

        $month = $v->monthname(1);
        isa_ok $month, 'ARRAY', $v.'->monthname(1)';
        is $month->[1], 'February', $v.'->monthname(1)->[1]';
        is $month->[8], 'September', $v.'->monthname(1)->[8]';
    }

    DAY_OF_WEEK: {
        my $dayofweek = undef;

        $dayofweek = $v->dayofweek(0);
        isa_ok $dayofweek, 'ARRAY', $v.'->dayofweek(0)';
        is $dayofweek->[1], 'Mon', $v.'->dayofweek(0)->[1]';
        is $dayofweek->[5], 'Fri', $v.'->dayofweek(0)->[5]';

        $dayofweek = $v->dayofweek(1);
        isa_ok $dayofweek, 'ARRAY', $v.'->dayofweek(1)';
        is $dayofweek->[0], 'Sunday', $v.'->dayofweek(1)->[0]';
        is $dayofweek->[6], 'Saturday', $v.'->dayofweek(1)->[6]';
    }

    HOURS: {
        my $hours = $v->hourname(1);

        isa_ok $hours, 'ARRAY', $v.'->hourname(1)';
        is $hours->[0], 'Midnight', $v.'->hourname(1)->[0]';
        is $hours->[6], 'Morning', $v.'->hourname(1)->[6]';
        is $hours->[12], 'Noon', $v.'->hourname(1)->[12]';
        is $hours->[18], 'Evening', $v.'->hourname(1)->[18]';
    }

    OFFSET2DATE: {
        my $date = q();
        my $base = new Time::Piece;
        my $time = undef;

        for my $e ( -2, -1, 0, 1, 2 ) {
            $date = $v->o2d( $e );
            $base = Time::Piece->strptime( $base->ymd, "%Y-%m-%d" );
            $time = Time::Piece->strptime( $date, "%Y-%m-%d" );
            like $date, qr/\A\d{4}[-]\d{2}[-]\d{2}\z/, 'offset = '.$e.', date = '.$date;
            is $time->epoch, $base->epoch - ( $e * 86400 );
        }

        for my $e ( 'a', ' ', 'string' ) {
            $date = $v->o2d( $e );
            $base = Time::Piece->strptime( $base->ymd, "%Y-%m-%d" );
            $time = Time::Piece->strptime( $date, "%Y-%m-%d" );
            like $date, qr/\A\d{4}[-]\d{2}[-]\d{2}\z/, 'offset = '.$e.', date = '.$date;
            is $time->epoch, $base->epoch;
        }
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
            my $text = $v->parse( $e );
            ok length $text, '->parse('.$e.') = '.$text;

            $text =~ s/\s+[-+]\d{4}\z//;
            $time = Time::Piece->strptime( $text, '%a, %d %b %Y %T' );
            isa_ok $time, 'Time::Piece';
            ok $time->cdate, '->cdate = '.$time->cdate;
        }

        for my $e ( @$invaliddates ) {
            my $text = $v->parse( $e, 1 );
            ok length( $text || '' ) == 0, '->parse('.$e.') = '.( $text || '' );
        }
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
            my $r = defined $e ? sprintf( "%#x", ord $e ) : 'undef';
            is $v->tz2second( $e ), undef, '->tz2second() The value: '.$r;
        }

        for my $e ( @{ $L->{'minus'} } ) {
            is $v->tz2second( $e ), undef, '->tz2second() The value: '.$e;
        }
    }
}

done_testing();
