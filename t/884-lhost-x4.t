use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X4';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.922', '',    'mailboxfull',     0]],
    '08' => [['4.4.1',   '',    'networkerror',    0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

