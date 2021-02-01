use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3834';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['',        '',    'vacation',        0]],
    '01002' => [['',        '',    'vacation',        0]],
    '01003' => [['',        '',    'vacation',        0]],
    '01004' => [['',        '',    'vacation',        0]],
    '01005' => [['',        '',    'vacation',        0]],
    '01006' => [['',        '',    'vacation',        0]],
    '01007' => [['',        '',    'vacation',        0]],
    '01008' => [['',        '',    'vacation',        0]],
    '01009' => [['',        '',    'vacation',        0]],
    '01010' => [['',        '',    'vacation',        0]],
    '01011' => [['',        '',    'vacation',        0]],
    '01012' => [['',        '',    'vacation',        0]],
    '01013' => [['',        '',    'vacation',        0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

