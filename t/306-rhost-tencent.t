use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Tencent';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.0',   '550', 'toomanyconn',     0]],
    '02' => [['5.0.0',   '550', 'toomanyconn',     0]],
    '03' => [['5.0.0',   '550', 'authfailure',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

