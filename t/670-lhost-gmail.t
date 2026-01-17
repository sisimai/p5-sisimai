use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Gmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '03' => [['5.7.0',   '554', 'filtered',        0, 1]],
    '04' => [['5.7.1',   '554', 'blocked',         0, 0]],
    '05' => [['5.7.1',   '550', 'securityerror',   0, 0]],
    '06' => [['4.2.2',   '450', 'mailboxfull',     0, 0]],
    '07' => [['5.9.350', '500', 'failedstarttls',  0, 0]],
    '08' => [['5.9.340', '',    'expired',         0, 0]],
    '09' => [['4.9.340', '',    'expired',         0, 0]],
    '10' => [['5.9.340', '',    'expired',         0, 0]],
    '11' => [['5.9.340', '',    'expired',         0, 0]],
    '15' => [['5.9.340', '',    'expired',         0, 0]],
    '16' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '17' => [['4.9.340', '',    'expired',         0, 0]],
    '18' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '19' => [['5.9.220', '',    'mailboxfull',     0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;


