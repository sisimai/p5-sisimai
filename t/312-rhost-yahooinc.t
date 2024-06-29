use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'YahooInc';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.9',   '554', 'policyviolation', 0]],
    '02' => [['4.7.0',   '421', 'rejected',        0]],
    '03' => [['5.0.0',   '554', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

