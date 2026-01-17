use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'TrendMicro';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1002'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1003'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1004'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1005'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1006'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1007'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1008'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1009'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1010'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1011'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1012'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1013'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1014'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1015'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1016'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1017'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1018'  => [['5.9.213', '',    'userunknown',     1, 1]],
};
plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

