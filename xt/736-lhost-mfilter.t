use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'mFILTER';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1002'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1003'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1004'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1005'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1006'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1007'  => [['5.9.213', '550', 'userunknown',     1, 1]],
    '1008'  => [['5.4.1',   '550', 'rejected',        0, 0]],
    '1009'  => [['5.4.1',   '550', 'rejected',        0, 0]],
    '1010'  => [['4.3.1',   '452', 'systemfull',      0, 0]],
    '1011'  => [['5.6.0',   '550', 'spamdetected',    0, 0]],
    '1012'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1013'  => [['5.9.210', '550', 'filtered',        0, 1]],
    '1014'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

