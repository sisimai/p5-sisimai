use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'KDDI';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.922', '',    'mailboxfull',     0]],
    '02' => [['5.0.922', '',    'mailboxfull',     0]],
    '03' => [['5.0.922', '',    'mailboxfull',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

