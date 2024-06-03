use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GoDaddy';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '02' => [['5.1.3',   '553', 'blocked',         0]],
    '03' => [['5.1.1',   '550', 'speeding',        0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

