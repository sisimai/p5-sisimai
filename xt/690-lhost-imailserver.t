use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'IMailServer';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.0.912', '',    'hostunknown',     1, 1]],
    '1002'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1003'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1004'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1005'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1006'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1007'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1008'  => [['5.0.912', '',    'hostunknown',     1, 1]],
    '1009'  => [['5.0.947', '',    'expired',         0, 0]],
    '1010'  => [['5.0.947', '',    'expired',         0, 0],
                ['5.0.947', '',    'expired',         0, 0]],
    '1011'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1012'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1013'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1014'  => [['5.0.912', '',    'hostunknown',     1, 1]],
    '1015'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1016'  => [['5.0.947', '',    'expired',         0, 0]],
    '1017'  => [['5.0.947', '',    'expired',         0, 0]],
    '1018'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1019'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1020'  => [['5.0.901', '',    'onhold',          0, 0]],
    '1021'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1022'  => [['5.0.911', '',    'userunknown',     1, 1],
                ['5.0.911', '',    'userunknown',     1, 1]],
    '1023'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
    '1024'  => [['5.0.901', '',    'onhold',          0, 0]],
    '1025'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1026'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1027'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1028'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1029'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1030'  => [['5.0.912', '',    'hostunknown',     1, 1]],
    '1031'  => [['5.0.912', '',    'hostunknown',     1, 1]],
    '1032'  => [['5.0.901', '',    'onhold',          0, 0]],
    '1033'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1034'  => [['5.0.911', '',    'userunknown',     1, 1]],
    '1035'  => [['5.0.980', '550', 'spamdetected',    0, 0]],
    '1036'  => [['5.0.980', '550', 'spamdetected',    0, 0]],
    '1037'  => [['5.0.980', '550', 'spamdetected',    0, 0]],
    '1038'  => [['5.0.922', '',    'mailboxfull',     0, 0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

