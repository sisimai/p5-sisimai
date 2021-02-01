use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Barracuda';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.1',   '550', 'spamdetected',    0]],
    '02' => [['5.7.1',   '550', 'spamdetected',    0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

