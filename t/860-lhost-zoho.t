use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Zoho';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.2.1',   '550', 'filtered',        0, 1],
             ['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '03' => [['5.9.210', '550', 'filtered',        0, 1]],
    '04' => [['4.9.340', '421', 'expired',         0, 0]],
    '05' => [['4.9.340', '421', 'expired',         0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

