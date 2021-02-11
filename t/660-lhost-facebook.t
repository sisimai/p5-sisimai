use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Facebook';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '03' => [['5.1.1',   '550', 'filtered',        0]],
    '04' => [['5.1.1',   '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

