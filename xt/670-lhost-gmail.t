use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Gmail';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.9.340', '',    'expired',         0, 0]],
    '1002'  => [['5.2.1',   '550', 'suspend',         0, 1]],
    '1003'  => [['4.9.340', '',    'expired',         0, 0]],
    '1004'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1005'  => [['4.9.340', '',    'expired',         0, 0]],
    '1006'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1007'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1008'  => [['5.9.340', '',    'expired',         0, 0]],
    '1009'  => [['4.9.340', '',    'expired',         0, 0]],
    '1010'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1011'  => [['4.2.2',   '450', 'mailboxfull',     0, 0]],
    '1012'  => [['4.9.340', '',    'expired',         0, 0]],
    '1013'  => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '1014'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1015'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1016'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1017'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1018'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1019'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1020'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1021'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1022'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1023'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1024'  => [['5.0.0',   '553', 'blocked',         0, 0]],
    '1025'  => [['5.7.0',   '554', 'filtered',        0, 1]],
    '1026'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1027'  => [['5.7.1',   '550', 'securityerror',   0, 0]],
    '1028'  => [['5.9.350', '500', 'failedstarttls',  0, 0]],
    '1029'  => [['5.9.301', '',    'onhold',          0, 0]],
    '1030'  => [['5.7.1',   '554', 'blocked',         0, 0]],
    '1031'  => [['5.7.1',   '550', 'blocked',         0, 0]],
    '1032'  => [['5.9.340', '',    'expired',         0, 0]],
    '1033'  => [['5.9.134', '',    'blocked',         0, 0]],
    '1034'  => [['4.9.340', '',    'expired',         0, 0]],
    '1035'  => [['4.9.134', '',    'blocked',         0, 0]],
    '1036'  => [['4.9.134', '',    'blocked',         0, 0]],
    '1037'  => [['5.9.134', '',    'blocked',         0, 0]],
    '1038'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1039'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1040'  => [['5.9.340', '',    'expired',         0, 0]],
    '1041'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1042'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1043'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1044'  => [['5.9.131', '',    'ratelimited',     0, 0]],
    '1045'  => [['5.9.340', '',    'expired',         0, 0]],
    '1046'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1047'  => [['5.1.1',   '550', 'userunknown',     1, 1],
                ['5.1.1',   '550', 'userunknown',     1, 1],
                ['5.1.1',   '550', 'userunknown',     1, 1]],
    '1048'  => [['5.9.220', '',    'mailboxfull',     0, 0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

