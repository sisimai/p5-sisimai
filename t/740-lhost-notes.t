use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Notes';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.301', '',    'onhold',          0, 0]],
    '02' => [['5.9.213', '',    'userunknown',     1, 1]],
    '03' => [['5.9.213', '',    'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

