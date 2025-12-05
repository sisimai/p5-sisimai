use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MessagingServer';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.2.0',   '',    'mailboxfull',     0, 1]],
    '03' => [['5.7.1',   '550', 'filtered',        0, 1],
             ['5.7.1',   '550', 'filtered',        0, 1]],
    '04' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '05' => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '06' => [['5.2.1',   '550', 'filtered',        0, 1]],
    '07' => [['4.4.7',   '',    'expired',         0, 0]],
    '08' => [['5.0.0',   '550', 'filtered',        0, 1]],
    '09' => [['5.0.0',   '550', 'userunknown',     1, 1]],
    '10' => [['5.1.10',  '',    'notaccept',       1, 1]],
    '11' => [['5.1.8',   '501', 'rejected',        0, 0]],
    '12' => [['4.2.2',   '',    'mailboxfull',     0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

