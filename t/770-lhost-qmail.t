use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'qmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.5.0',   '550', 'userunknown',     1, 1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1, 1],
             ['5.2.1',   '550', 'userunknown',     1, 1]],
    '03' => [['5.7.1',   '550', 'rejected',        0, 0]],
    '04' => [['5.0.0',   '501', 'blocked',         0, 0]],
    '05' => [['4.4.3',   '',    'systemerror',     0, 0]],
    '06' => [['4.2.2',   '450', 'mailboxfull',     0, 0]],
    '07' => [['4.4.1',   '',    'networkerror',    0, 0]],
    '08' => [['5.9.220', '552', 'mailboxfull',     0, 1]],
    '09' => [['5.7.606', '550', 'blocked',         0, 0]],
    '10' => [['5.9.221', '',    'suspend',         0, 1]],
    '11' => [['5.4.4',   '',    'notaccept',       1, 1]],
    '12' => [['5.4.4',   '',    'notaccept',       1, 1]],
    '13' => [['5.1.2',   '',    'hostunknown',     1, 1]],
    '14' => [['5.7.26',  '550', 'authfailure',     0, 0]],
    '15' => [['5.7.509', '550', 'authfailure',     0, 0]],
    '16' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '17' => [['5.1.1',   '550', 'userunknown',     1, 1],
             ['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '18' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '19' => [['4.7.0',   '421', 'badreputation',   0, 0]],
    '20' => [['5.7.26',  '550', 'authfailure',     0, 0]],
    '21' => [['5.1.1',   '',    'userunknown',     1, 1]],
    '22' => [['5.7.509', '550', 'authfailure',     0, 0]],
    '23' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '24' => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '25' => [['5.2.2',   '552', 'mailboxfull',     0, 1],
             ['5.1.1',   '550', 'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

