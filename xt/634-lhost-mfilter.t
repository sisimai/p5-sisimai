use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'mFILTER';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.910', '550', 'filtered',        0]],
    '01002' => [['5.1.1',   '550', 'userunknown',     1]],
    '01003' => [['5.0.910', '550', 'filtered',        0]],
    '01004' => [['5.0.910', '550', 'filtered',        0]],
    '01005' => [['5.1.1',   '550', 'userunknown',     1]],
    '01006' => [['5.0.910', '550', 'filtered',        0]],
    '01007' => [['5.0.910', '550', 'filtered',        0]],
    '01008' => [['5.4.1',   '550', 'rejected',        0]],
    '01009' => [['5.4.1',   '550', 'rejected',        0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

