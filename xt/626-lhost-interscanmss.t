use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'InterScanMSS';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'userunknown',     1]],
    '01002' => [['5.1.1',   '550', 'userunknown',     1]],
    '01003' => [['5.1.1',   '550', 'userunknown',     1]],
    '01004' => [['5.1.1',   '550', 'userunknown',     1]],
    '01005' => [['5.0.911', '',    'userunknown',     1]],
    '01006' => [['5.1.1',   '550', 'userunknown',     1]],
    '01007' => [['5.1.1',   '550', 'userunknown',     1]],
    '01008' => [['5.0.911', '',    'userunknown',     1]],
    '01009' => [['5.0.911', '',    'userunknown',     1]],
    '01010' => [['5.0.911', '',    'userunknown',     1]],
    '01011' => [['5.0.911', '',    'userunknown',     1]],
    '01012' => [['5.0.911', '',    'userunknown',     1]],
    '01013' => [['5.0.911', '',    'userunknown',     1]],
    '01014' => [['5.0.911', '',    'userunknown',     1]],
    '01015' => [['5.0.911', '',    'userunknown',     1]],
    '01016' => [['5.0.911', '',    'userunknown',     1]],
    '01017' => [['5.0.911', '',    'userunknown',     1]],
    '01018' => [['5.0.911', '',    'userunknown',     1]],

};
plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

