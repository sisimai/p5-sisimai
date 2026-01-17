use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GMX';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.2.2',   '',    'mailboxfull',     0, 1]],
    '02' => [['5.1.1',   '',    'userunknown',     1, 1]],
    '03' => [['5.2.1',   '',    'userunknown',     1, 1],
             ['5.2.2',   '',    'mailboxfull',     0, 1]],
    '04' => [['5.9.340', '',    'expired',         0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

