use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X2';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.910', '',    'filtered',        0]],
    '02' => [['5.0.910', '',    'filtered',        0],
             ['5.0.921', '',    'suspend',         0],
             ['5.0.910', '',    'filtered',        0]],
    '03' => [['5.0.947', '',    'expired',         0]],
    '04' => [['5.0.922', '',    'mailboxfull',     0]],
    '05' => [['4.1.9',   '',    'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

