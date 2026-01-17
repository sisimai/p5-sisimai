use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'mFILTER';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.210', '550', 'filtered',        0, 1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '03' => [['5.9.210', '550', 'filtered',        0, 1]],
    '04' => [['5.4.1',   '550', 'rejected',        0, 0]],
    '05' => [['4.3.1',   '452', 'systemfull',      0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

