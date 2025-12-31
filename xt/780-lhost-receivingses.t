use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ReceivingSES';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.2.3',   '552', 'emailtoolarge',  0, 0]],
};

plan 'skip_all', sprintf("no private sample");
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

