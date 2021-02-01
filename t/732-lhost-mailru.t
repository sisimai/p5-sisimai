use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MailRu';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '03' => [['5.2.2',   '550', 'mailboxfull',     0],
             ['5.2.1',   '550', 'userunknown',     1]],
    '04' => [['5.1.1',   '550', 'userunknown',     1]],
    '05' => [['5.0.932', '',    'notaccept',       1]],
    '06' => [['5.0.912', '',    'hostunknown',     1]],
    '07' => [['5.0.910', '550', 'filtered',        0]],
    '08' => [['5.0.911', '550', 'userunknown',     1]],
    '09' => [['5.1.8',   '501', 'rejected',        0]],
    '10' => [['5.0.947', '',    'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

