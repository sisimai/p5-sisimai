use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Aol';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '1002'  => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '1003'  => [['5.2.2',   '550', 'mailboxfull',     0, 1],
                ['5.1.1',   '550', 'userunknown',     1, 1]],
    '1004'  => [['5.2.2',   '550', 'mailboxfull',     0, 1],
                ['5.1.1',   '550', 'userunknown',     1, 1]],
    '1005'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1006'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1007'  => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '1008'  => [['5.7.1',   '554', 'filtered',        0, 1]],
    '1009'  => [['5.7.1',   '554', 'policyviolation', 0, 0]],
    '1010'  => [['5.7.1',   '554', 'filtered',        0, 1]],
    '1011'  => [['5.7.1',   '554', 'filtered',        0, 1]],
    '1012'  => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '1013'  => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '1014'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

