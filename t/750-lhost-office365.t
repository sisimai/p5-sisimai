use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Office365';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.10',  '550', 'userunknown',     1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1]],
    '03' => [['5.1.0',   '550', 'blocked',         0]],
    '04' => [['5.1.351', '550', 'filtered',        0]],
    '05' => [['5.1.8',   '501', 'rejected',        0]],
    '06' => [['5.4.312', '550', 'networkerror',    0]],
    '07' => [['5.1.351', '550', 'userunknown',     1]],
    '08' => [['5.4.316', '550', 'expired',         0]],
    '09' => [['5.1.351', '550', 'userunknown',     1]],
    '10' => [['5.1.351', '550', 'userunknown',     1]],
    '11' => [['5.1.1',   '550', 'userunknown',     1]],
    '12' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '13' => [['5.1.10',  '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

