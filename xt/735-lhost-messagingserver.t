use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MessagingServer';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '1002'  => [['5.0.0',   '',    'mailboxfull',     0, 1]],
    '1003'  => [['5.7.1',   '550', 'filtered',        0, 1],
                ['5.7.1',   '550', 'filtered',        0, 1]],
    '1004'  => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '1005'  => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '1006'  => [['5.7.1',   '550', 'filtered',        0, 1]],
    '1007'  => [['5.2.0',   '',    'mailboxfull',     0, 1]],
    '1008'  => [['5.2.1',   '550', 'filtered',        0, 1]],
    '1009'  => [['5.0.0',   '',    'mailboxfull',     0, 1]],
    '1010'  => [['5.2.0',   '',    'mailboxfull',     0, 1]],
    '1011'  => [['4.4.7',   '',    'expired',         0, 0]],
    '1012'  => [['5.0.0',   '550', 'filtered',        0, 1]],
    '1013'  => [['4.2.2',   '',    'mailboxfull',     0, 0]],
    '1014'  => [['4.2.2',   '',    'mailboxfull',     0, 0]],
    '1015'  => [['5.0.0',   '550', 'filtered',        0, 1]],
    '1016'  => [['5.0.0',   '550', 'userunknown',     1, 1]],
    '1017'  => [['5.1.10',  '',    'notaccept',       1, 1]],
    '1018'  => [['5.1.8',   '501', 'rejected',        0, 0]],
    '1019'  => [['4.2.2',   '',    'mailboxfull',     0, 0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

