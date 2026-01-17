use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X2';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.7.1',   '554', 'norelaying',      0, 1]],
    '1002'  => [['5.9.210', '',    'filtered',        0, 0]],
    '1003'  => [['5.9.210', '',    'filtered',        0, 0]],
    '1004'  => [['5.9.210', '',    'filtered',        0, 0],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.210', '',    'filtered',        0, 0]],
    '1005'  => [['5.9.340', '',    'expired',         0, 0]],
    '1006'  => [['5.1.2',   '',    'hostunknown',     1, 1]],
    '1007'  => [['5.9.340', '',    'expired',         0, 0]],
    '1008'  => [['4.4.1',   '',    'expired',         0, 0]],
    '1009'  => [['5.9.220', '',    'mailboxfull',     0, 0]],
    '1010'  => [['5.9.221', '',    'suspend',         0, 1]],
    '1011'  => [['5.9.220', '',    'mailboxfull',     0, 0],
                ['5.9.220', '',    'mailboxfull',     0, 0]],
    '1012'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1013'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1014'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1015'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1016'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1017'  => [['5.9.210', '',    'filtered',        0, 0],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.210', '',    'filtered',        0, 0]],
    '1018'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1019'  => [['5.9.220', '',    'mailboxfull',     0, 0]],
    '1020'  => [['5.9.210', '',    'filtered',        0, 0]],
    '1021'  => [['5.9.210', '',    'filtered',        0, 0],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.210', '',    'filtered',        0, 0]],
    '1022'  => [['5.9.210', '',    'filtered',        0, 0]],
    '1023'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1024'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1025'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1026'  => [['5.9.221', '',    'suspend',         0, 1],
                ['5.9.221', '',    'suspend',         0, 1]],
    '1027'  => [['5.9.220', '',    'mailboxfull',     0, 0],
                ['5.9.220', '',    'mailboxfull',     0, 0]],
    '1028'  => [['4.4.1',   '',    'expired',         0, 0]],
    '1029'  => [['4.1.9',   '',    'expired',         0, 0]],
    '1030'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1031'  => [['5.4.14',  '554', 'networkerror',    0, 0]],
    '1032'  => [['5.4.14',  '554', 'networkerror',    0, 0]],
    '1033'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

