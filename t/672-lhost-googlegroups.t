use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GoogleGroups';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.9.110', '',    'rejected',        0, 0]],
    '02' => [['5.9.110', '',    'rejected',        0, 0]],
    '03' => [['5.9.110', '',    'rejected',        0, 0]],
    '04' => [['5.9.110', '',    'rejected',        0, 0]],
    '05' => [['5.9.110', '',    'rejected',        0, 0]],
    '06' => [['5.9.110', '',    'rejected',        0, 0]],
    '07' => [['5.9.110', '',    'rejected',        0, 0]],
    '08' => [['5.9.110', '',    'rejected',        0, 0]],
    '09' => [['5.9.110', '',    'rejected',        0, 0]],
    '10' => [['5.9.110', '',    'rejected',        0, 0]],
    '11' => [['5.9.110', '',    'rejected',        0, 0]],
    '12' => [['5.9.110', '',    'rejected',        0, 0]],
    '13' => [['5.9.110', '',    'rejected',        0, 0]],
    '14' => [['5.9.110', '',    'rejected',        0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

