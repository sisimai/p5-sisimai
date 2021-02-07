use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Notes';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.911', '',    'userunknown',     1]],
    '01002' => [['5.0.901', '',    'onhold',          0]],
    '01003' => [['5.0.901', '',    'onhold',          0]],
    '01004' => [['5.0.911', '',    'userunknown',     1]],
    '01005' => [['5.0.901', '',    'onhold',          0]],
    '01006' => [['5.0.911', '',    'userunknown',     1]],
    '01007' => [['5.0.911', '',    'userunknown',     1]],
    '01008' => [['5.0.911', '',    'userunknown',     1]],
    '01009' => [['5.0.911', '',    'userunknown',     1]],
    '01010' => [['5.0.944', '',    'networkerror',    0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

