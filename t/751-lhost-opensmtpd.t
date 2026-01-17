use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'OpenSMTPD';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0, 1],
             ['5.1.1',   '550', 'userunknown',     1, 1]],
    '03' => [['5.9.212', '',    'hostunknown',     1, 1]],
    '04' => [['5.9.341', '',    'networkerror',    0, 0]],
    '05' => [['5.9.340', '',    'expired',         0, 0]],
    '06' => [['5.9.340', '',    'expired',         0, 0]],
    '10' => [['5.9.212', '',    'hostunknown',     1, 1]],
    '11' => [['5.7.26',  '550', 'authfailure',     0, 0]],
    '12' => [['5.9.215', '',    'notaccept',       1, 1]],
    '13' => [['4.7.0',   '421', 'badreputation',   0, 0]],
    '14' => [['5.7.25',  '550', 'requireptr',      0, 0]],
    '15' => [['5.9.340', '',    'expired',         0, 0]],
    '16' => [['5.9.340', '',    'expired',         0, 0]],
    '17' => [['5.1.1',   '550', 'userunknown',     1, 1],
             ['5.2.2',   '552', 'mailboxfull',     0, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

