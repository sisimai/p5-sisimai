use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3834';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['',        '', 'vacation', 0, 0]],
    '02' => [['',        '', 'vacation', 0, 0]],
    '03' => [['',        '', 'vacation', 0, 0]],
    '04' => [['',        '', 'vacation', 0, 0]],
    '05' => [['',        '', 'vacation', 0, 0]],
    '06' => [['5.9.221', '', 'suspend',  0, 1]],
};
$enginetest->($enginename, $isexpected);

is Sisimai::RFC3834->inquire({}), undef;
is Sisimai::RFC3834->inquire({'neko' => 2}, []), undef;

done_testing;

