use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Zoho';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.7.7',   '554', 'policyviolation', 0, 0]],
    '03' => [['5.7.1',   '554', 'rejected',        0, 0]],
    '04' => [['5.4.1',   '',    'rejected',        0, 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

