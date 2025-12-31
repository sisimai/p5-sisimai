use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ReceivingSES';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '03' => [['4.0.0',   '450', 'onhold',          0, 0]],
    '04' => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
    '05' => [['5.3.4',   '552', 'emailtoolarge',   0, 0]],
    '06' => [['5.6.1',   '500', 'spamdetected',    0, 0]],
    '07' => [['5.2.0',   '550', 'filtered',        0, 1]],
    '08' => [['5.2.3',   '552', 'emailtoolarge',   0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

