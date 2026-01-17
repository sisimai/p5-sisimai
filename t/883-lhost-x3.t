use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X3';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.3.0',   '553', 'userunknown',     1, 1]],
    '02' => [['5.9.340', '',    'expired',         0, 0]],
    '03' => [['5.3.0',   '553', 'userunknown',     1, 1]],
    '05' => [['5.9.300', '',    'undefined',       0, 0]],
    '06' => [['5.2.2',   '552', 'mailboxfull',     0, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

