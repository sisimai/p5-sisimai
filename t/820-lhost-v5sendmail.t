use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'V5sendmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['4.9.344', '421', 'expired',         0, 0]],
    '02' => [['5.9.212', '550', 'hostunknown',     1, 1]],
    '03' => [['5.9.213', '550', 'userunknown',     1, 1]],
    '04' => [['5.9.212', '550', 'hostunknown',     1, 1],
             ['5.9.212', '550', 'hostunknown',     1, 1]],
    '05' => [['5.9.231', '550', 'systemerror',     0, 0],
             ['5.9.212', '550', 'hostunknown',     1, 1],
             ['5.9.212', '550', 'hostunknown',     1, 1],
             ['5.9.213', '550', 'userunknown',     1, 1]],
    '06' => [['5.9.214', '550', 'norelaying',      0, 1]],
    '07' => [['5.9.134', '554', 'blocked',         0, 0],
             ['5.9.212', '550', 'hostunknown',     1, 1],
             ['5.9.213', '550', 'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

