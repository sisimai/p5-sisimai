use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X3';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.3.0',   '553', 'userunknown',     1]],
    '02' => [['5.0.947', '',    'expired',         0]],
    '03' => [['5.3.0',   '553', 'userunknown',     1]],
    '05' => [['5.0.900', '',    'undefined',       0]],
    '06' => [['5.2.2',   '552', 'mailboxfull',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

