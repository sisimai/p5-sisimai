use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'DragonFly';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.26',  '550', 'authfailure',     0]],
    '02' => [['5.7.509', '550', 'authfailure',     0]],
    '03' => [['5.7.9',   '554', 'policyviolation', 0]],
    '04' => [['5.0.912', '',    'hostunknown',     1]],
    '05' => [['5.7.26',  '550', 'authfailure',     0]],
    '06' => [['5.7.25',  '550', 'requireptr',      0]],
    '07' => [['5.6.0',   '550', 'contenterror',    0]],
    '08' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '09' => [['5.2.1',   '550', 'userunknown',     1]],
    '10' => [['5.1.6',   '550', 'hasmoved',        1]],
    '11' => [['5.1.2',   '550', 'hostunknown',     1]],
    '12' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '13' => [['5.3.0',   '554', 'mailererror',     0]],
    '14' => [['5.3.4',   '554', 'mesgtoobig',      0]],
    '15' => [['5.7.0',   '550', 'norelaying',      0]],
    '16' => [['5.3.2',   '521', 'notaccept',       1]],
    '17' => [['5.0.0',   '550', 'onhold',          0]],
    '18' => [['5.7.0',   '550', 'securityerror',   0]],
    '19' => [['5.7.1',   '551', 'securityerror',   0]],
    '20' => [['5.7.0',   '550', 'spamdetected',    0]],
    '21' => [['5.7.13',  '525', 'suspend',         0]],
    '22' => [['5.1.3',   '501', 'userunknown',     1]],
    '23' => [['5.3.0',   '554', 'systemerror',     0]],
    '24' => [['5.1.1',   '550', 'userunknown',     1]],
    '25' => [['5.7.0',   '550', 'virusdetected',   0]],
    '26' => [['5.1.1',   '550', 'userunknown',     1]],
    '27' => [['5.7.13',  '525', 'suspend',         0]],
    '28' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '29' => [['5.0.947', '',    'expired',         0]],
    '30' => [['5.0.947', '',    'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

