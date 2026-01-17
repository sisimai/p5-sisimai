use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3834';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['',        '',    'vacation',        0, 0]],
    '1002'  => [['',        '',    'vacation',        0, 0]],
    '1003'  => [['',        '',    'vacation',        0, 0]],
    '1004'  => [['',        '',    'vacation',        0, 0]],
    '1005'  => [['',        '',    'vacation',        0, 0]],
    '1006'  => [['',        '',    'vacation',        0, 0]],
    '1007'  => [['',        '',    'vacation',        0, 0]],
    '1008'  => [['',        '',    'vacation',        0, 0]],
    '1009'  => [['',        '',    'vacation',        0, 0]],
    '1010'  => [['',        '',    'vacation',        0, 0]],
    '1011'  => [['',        '',    'vacation',        0, 0]],
    '1012'  => [['',        '',    'vacation',        0, 0]],
    '1013'  => [['',        '',    'vacation',        0, 0]],
    '1014'  => [['5.9.221', '',    'suspend',         0, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

