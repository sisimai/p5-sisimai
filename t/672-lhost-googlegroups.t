use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GoogleGroups';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.918', '',    'rejected',        0]],
    '02' => [['5.0.918', '',    'rejected',        0]],
    '03' => [['5.0.918', '',    'rejected',        0]],
    '04' => [['5.0.918', '',    'rejected',        0]],
    '05' => [['5.0.918', '',    'rejected',        0]],
    '06' => [['5.0.918', '',    'rejected',        0]],
    '07' => [['5.0.918', '',    'rejected',        0]],
    '08' => [['5.0.918', '',    'rejected',        0]],
    '09' => [['5.0.918', '',    'rejected',        0]],
    '10' => [['5.0.918', '',    'rejected',        0]],
    '11' => [['5.0.918', '',    'rejected',        0]],
    '12' => [['5.0.918', '',    'rejected',        0]],
    '13' => [['5.0.918', '',    'rejected',        0]],
    '14' => [['5.0.918', '',    'rejected',        0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

