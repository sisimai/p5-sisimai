use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'FrancePTT';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.5.0',   '550', 'userunknown',     1]],
    '03' => [['5.2.0',   '550', 'spamdetected',    0]],
    '04' => [['5.2.0',   '550', 'spamdetected',    0]],
    '05' => [['5.5.0',   '550', 'suspend',         0]],
    '06' => [['4.0.0',   '',    'blocked',         0]],
    '07' => [['4.0.0',   '421', 'blocked',         0]],
    '08' => [['4.2.0',   '421', 'systemerror',     0]],
    '10' => [['5.5.0',   '550', 'undefined',       0]],
    '11' => [['4.2.1',   '421', 'undefined',       0]],
    '12' => [['5.7.1',   '554', 'policyviolation', 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

