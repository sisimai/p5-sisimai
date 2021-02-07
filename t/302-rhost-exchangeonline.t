use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ExchangeOnline';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.606', '550', 'blocked',         0]],
    '02' => [['5.4.1',   '550', 'rejected',        0]],
    '03' => [['5.1.10',  '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

