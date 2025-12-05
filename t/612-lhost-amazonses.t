use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'AmazonSES';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.7.1',   '550', 'securityerror',   0, 0]],
    '02' => [['5.3.0',   '550', 'filtered',        0, 1]],
    '03' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '05' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '06' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '07' => [['5.7.6',   '550', 'securityerror',   0, 0]],
    '08' => [['5.7.9',   '550', 'securityerror',   0, 0]],
    '09' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '10' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '11' => [['',        '',    'feedback',        0, 1, 'abuse']],
    '12' => [['2.6.0',   '250', 'delivered',       0, 0]],
    '13' => [['2.6.0',   '250', 'delivered',       0, 0]],
    '14' => [['5.7.1',   '554', 'blocked',         0, 0]],
    '15' => [['5.7.1',   '554', 'blocked',         0, 0]],
    '16' => [['5.7.1',   '521', 'blocked',         0, 0]],
    '17' => [['4.4.2',   '421', 'expired',         0, 0]],
    '18' => [['5.4.4',   '550', 'hostunknown',     1, 1]],
    '19' => [['5.7.1',   '550', 'suspend',         0, 1]],
    '20' => [['5.2.1',   '550', 'suspend',         0, 1]],
    '21' => [['5.7.1',   '554', 'norelaying',      0, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

