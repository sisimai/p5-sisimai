use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GSuite';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.0',   '550', 'userunknown',     1]],
    '02' => [['5.0.0',   '',    'userunknown',     1]],
    '03' => [['4.0.0',   '',    'notaccept',       0]],
    '04' => [['4.0.0',   '',    'networkerror',    0]],
    '05' => [['4.0.0',   '',    'networkerror',    0]],
    '06' => [['4.4.1',   '',    'expired',         0]],
    '07' => [['4.4.1',   '',    'expired',         0]],
    '08' => [['5.0.0',   '550', 'filtered',        0]],
    '09' => [['5.0.0',   '550', 'userunknown',     1]],
    '10' => [['4.0.0',   '',    'notaccept',       0]],
    '11' => [['5.1.8',   '501', 'rejected',        0]],
    '12' => [['5.0.0',   '',    'spamdetected',    0]],
    '13' => [['4.0.0',   '',    'networkerror',    0]],
    '14' => [['5.1.1',   '550', 'userunknown',     1]],
    '15' => [['4.0.0',   '',    'networkerror',    0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

