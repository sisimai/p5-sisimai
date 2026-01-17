use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2003';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.213', '',    'userunknown',     1, 1]],
    '02' => [['5.9.213', '',    'userunknown',     1, 1],
             ['5.9.213', '',    'userunknown',     1, 1]],
    '03' => [['5.9.213', '',    'userunknown',     1, 1]],
    '04' => [['5.9.210', '',    'filtered',        0, 0]],
    '05' => [['5.9.213', '',    'userunknown',     1, 1]],
    '07' => [['5.9.213', '',    'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

