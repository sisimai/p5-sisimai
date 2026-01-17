use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Domino';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.0.0',   '',    'onhold',          0, 0]],
    '1002'  => [['5.1.1',   '',    'userunknown',     1, 1]],
    '1003'  => [['5.0.0',   '',    'userunknown',     1, 1]],
    '1004'  => [['5.0.0',   '',    'userunknown',     1, 1]],
    '1005'  => [['5.0.0',   '',    'onhold',          0, 0]],
    '1006'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1007'  => [['5.0.0',   '',    'userunknown',     1, 1]],
    '1008'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1009'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1010'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1011'  => [['5.1.1',   '',    'userunknown',     1, 1]],
    '1012'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1013'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1014'  => [['5.9.213', '',    'userunknown',     1, 1]],
    '1015'  => [['5.0.0',   '',    'networkerror',    0, 0]],
    '1016'  => [['5.0.0',   '',    'systemerror',     0, 0]],
    '1017'  => [['5.0.0',   '',    'userunknown',     1, 1]],
    '1019'  => [['5.0.0',   '',    'userunknown',     1, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

