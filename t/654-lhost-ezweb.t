use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'EZweb';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.210', '',    'filtered',        0, 1]],
    '02' => [['5.0.0',   '550', 'suspend',         0, 1]],
    '03' => [['5.9.221', '',    'suspend',         0, 1]],
    '04' => [['5.9.213', '550', 'userunknown',     1, 1]],
    '05' => [['5.9.340', '',    'expired',         0, 0]],
    '07' => [['5.9.213', '550', 'userunknown',     1, 1]],
    '08' => [['5.9.134', '550', 'blocked',         0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

