use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP::Failure;

my $Package = 'Sisimai::SMTP::Failure';
my $Methods = { 'class' => ['is_permanent', 'is_temporary', 'is_hardbounce', 'is_softbounce'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $softbounces = [
        'blocked', 'contenterror', 'exceedlimit', 'expired', 'filtered',
        'mailboxfull', 'mailererror', 'mesgtoobig', 'networkerror',
        'norelaying', 'rejected', 'securityerror',
        'spamdetected', 'suspend', 'systemerror', 'systemfull', 'toomanyconn',
        'undefined', 'onhold',
    ];
    my $hardbounces = ['userunknown', 'hostunknown', 'hasmoved', 'notaccept'];
    my $isntbounces = ['delivered', 'feedback', 'vacation'];

    my $isnterrors = [
        'smtp; 2.1.5 250 OK',
    ];
    my $temperrors = [
        'smtp; 450 4.0.0 Temporary failure',
        'smtp; 554 4.4.7 Message expired: unable to deliver in 840 minutes.<421 4.4.2 Connection timed out>',
        'SMTP; 450 4.7.1 Access denied. IP name lookup failed [192.0.2.222]',
        'smtp; 451 4.7.650 The mail server [192.0.2.25] has been',
        '4.4.1 (Persistent transient failure - routing/network: no answer from host)',
    ];
    my $permerrors = [
        'smtp;550 5.2.2 <mikeneko@example.co.jp>... Mailbox Full',
        'smtp; 550 5.1.1 Mailbox does not exist',
        'smtp; 550 5.1.1 Mailbox does not exist',
        'smtp; 552 5.2.2 Mailbox full',
        'smtp; 552 5.3.4 Message too large',
        'smtp; 500 5.6.1 Message content rejected',
        'smtp; 550 5.2.0 Message Filtered',
        '550 5.1.1 <kijitora@example.jp>... User Unknown',
        'SMTP; 552-5.7.0 This message was blocked because its content presents a potential',
        'SMTP; 550 5.1.1 Requested action not taken: mailbox unavailable',
        'SMTP; 550 5.7.1 IP address blacklisted by recipient',
    ];
    my $v = undef;

    is $Package->is_permanent(), 0;
    for my $e ( @$isnterrors ) {
        is $Package->is_permanent($e), 0, '->is_permanent('.$e.') = 0';
        is $Package->is_temporary($e), 0, '->is_temporary('.$e.') = 0';
    }

    for my $e ( @$temperrors ) {
        is $Package->is_permanent($e), 0, '->is_permanent('.$e.') = 0';
        is $Package->is_temporary($e), 1, '->is_temporary('.$e.') = 1';
    }

    for my $e ( @$permerrors ) {
        is $Package->is_permanent($e), 1, '->is_permanent('.$e.') = 1';
        is $Package->is_temporary($e), 0, '->is_temporary('.$e.') = 0';
    }

    for my $e ( @$softbounces ) {
        is $Package->is_hardbounce($e), 0, '->is_hardbounce('.$e.') = 0';
        is $Package->is_softbounce($e), 1, '->is_softbounce('.$e.') = 1';
    }

    for my $e ( @$hardbounces ) {
        is $Package->is_hardbounce($e), 1, '->is_hardbounce('.$e.') = 1';
        is $Package->is_softbounce($e), 0, '->is_softbounce('.$e.') = 0';

        if( $e eq 'notaccept' ) {
            $v = '503 Not accept any email';
            is $Package->is_hardbounce($e, $v), 1, '->is_hardbounce('.$e.','.$v.') = 1';
            is $Package->is_softbounce($e, $v), 0, '->is_softbounce('.$e.','.$v.') = 0';

            $v = '458 Not accept any email';
            is $Package->is_hardbounce($e, $v), 0, '->is_hardbounce('.$e.','.$v.') = 0';
            is $Package->is_softbounce($e, $v), 1, '->is_softbounce('.$e.','.$v.') = 1';
        }
    }

    for my $e ( @$isntbounces ) {
        is $Package->is_hardbounce($e), 0, '->is_hardbounce('.$e.') = 0';
        is $Package->is_softbounce($e), 0, '->is_softbounce('.$e.') = 0';
    }
}

done_testing;

