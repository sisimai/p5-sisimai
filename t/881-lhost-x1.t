use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X1';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.210', '',    'filtered',        0, 0]],
    '02' => [['5.9.210', '',    'filtered',        0, 0]],
    '03' => [['5.9.210', '',    'filtered',        0, 0]],
    '04' => [['5.9.340', '',    'expired',         0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

