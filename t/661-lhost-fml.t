use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'FML';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '02' => [['5.9.110', '',    'rejected',        0, 0]],
    '03' => [['5.9.162', '',    'notcompliantrfc', 0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

