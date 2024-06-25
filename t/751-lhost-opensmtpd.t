use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'OpenSMTPD';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0],
             ['5.1.1',   '550', 'userunknown',     1]],
    '03' => [['5.0.912', '',    'hostunknown',     1]],
    '04' => [['5.0.944', '',    'networkerror',    0]],
    '05' => [['5.0.947', '',    'expired',         0]],
    '06' => [['5.0.947', '',    'expired',         0]],
    '10' => [['5.0.912', '',    'hostunknown',     1]],
    '11' => [['5.7.26',  '550', 'authfailure',     0]],
    '12' => [['5.0.932', '',    'notaccept',       1]],
    '13' => [['4.7.0',   '421', 'badreputation',   0]],
    '14' => [['5.7.25',  '550', 'requireptr',      0]],
    '15' => [['5.0.947', '',    'expired',         0]],
    '16' => [['5.0.947', '',    'expired',         0]],
    '17' => [['5.1.1',   '550', 'userunknown',     1],
             ['5.2.2',   '552', 'mailboxfull',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

