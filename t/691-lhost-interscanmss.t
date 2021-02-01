use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'InterScanMSS';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.0.911', '',    'userunknown',     1]],
    '03' => [['5.0.911', '',    'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

