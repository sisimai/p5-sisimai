use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Zoho';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.2.1',   '550', 'filtered',        0],
             ['5.2.2',   '550', 'mailboxfull',     0]],
    '03' => [['5.0.910', '550', 'filtered',        0]],
    '04' => [['4.0.947', '421', 'expired',         0]],
    '05' => [['4.0.947', '421', 'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

