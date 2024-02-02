use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GoogleGroups';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.918', '',    'rejected',        0]],
    '01002' => [['5.0.918', '',    'rejected',        0]],
    '01003' => [['5.0.918', '',    'rejected',        0]],
    '01004' => [['5.0.918', '',    'rejected',        0]],
    '01005' => [['5.0.918', '',    'rejected',        0]],
    '01006' => [['5.0.918', '',    'rejected',        0]],
    '01007' => [['5.0.918', '',    'rejected',        0]],
    '01008' => [['5.0.918', '',    'rejected',        0]],
    '01009' => [['5.0.918', '',    'rejected',        0]],
    '01010' => [['5.0.918', '',    'rejected',        0]],
    '01011' => [['5.0.918', '',    'rejected',        0]],
    '01012' => [['5.0.918', '',    'rejected',        0]],
    '01013' => [['5.0.918', '',    'rejected',        0]],
    '01014' => [['5.0.918', '',    'rejected',        0]],
    '01015' => [['5.0.918', '',    'rejected',        0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

