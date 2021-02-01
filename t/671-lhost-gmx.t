use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GMX';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.2.2',   '',    'mailboxfull',     0]],
    '02' => [['5.1.1',   '',    'userunknown',     1]],
    '03' => [['5.2.1',   '',    'userunknown',     1],
             ['5.2.2',   '',    'mailboxfull',     0]],
    '04' => [['5.0.947', '',    'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

