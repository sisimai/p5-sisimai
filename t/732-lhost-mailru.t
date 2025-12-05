use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MailRu';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '03' => [['5.2.2',   '550', 'mailboxfull',     0, 1],
             ['5.2.1',   '550', 'userunknown',     1, 1]],
    '04' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '05' => [['5.0.932', '',    'notaccept',       1, 1]],
    '06' => [['5.0.912', '',    'hostunknown',     1, 1]],
    '07' => [['5.0.910', '550', 'filtered',        0, 1]],
    '08' => [['5.0.911', '550', 'userunknown',     1, 1]],
    '09' => [['5.1.8',   '501', 'rejected',        0, 0]],
    '10' => [['4.0.947', '',    'expired',         0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

