use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'FrancePTT';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.5.0',   '550', 'userunknown',     1, 1]],
    '03' => [['5.2.0',   '550', 'spamdetected',    0, 0]],
    '04' => [['5.2.0',   '550', 'spamdetected',    0, 0]],
    '05' => [['5.5.0',   '550', 'suspend',         0, 1]],
    '06' => [['4.0.0',   '',    'blocked',         0, 0]],
    '07' => [['4.0.0',   '421', 'ratelimited',     0, 0]],
    '08' => [['4.2.0',   '421', 'systemerror',     0, 0]],
    '10' => [['5.5.0',   '550', 'blocked',         0, 0]],
    '11' => [['4.2.1',   '421', 'requireptr',      0, 0]],
    '12' => [['5.7.1',   '554', 'policyviolation', 0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

