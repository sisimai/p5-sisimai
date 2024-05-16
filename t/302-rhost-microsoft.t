use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Microsoft';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.606', '550', 'blocked',         0]],
    '02' => [['5.4.1',   '550', 'userunknown',     1]],
    '03' => [['5.1.10',  '550', 'userunknown',     1]],
    '04' => [['5.7.509', '550', 'authfailure',     0]],
    '05' => [['4.7.650', '451', 'badreputation',   0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

