use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X6';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.4.6',   '554', 'networkerror',    0]],
    '02' => [['5.1.1',   '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

