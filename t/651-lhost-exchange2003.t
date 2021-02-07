use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2003';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.911', '',    'userunknown',     1]],
    '02' => [['5.0.911', '',    'userunknown',     1],
             ['5.0.911', '',    'userunknown',     1]],
    '03' => [['5.0.911', '',    'userunknown',     1]],
    '04' => [['5.0.910', '',    'filtered',        0]],
    '05' => [['5.0.911', '',    'userunknown',     1]],
    '07' => [['5.0.911', '',    'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

