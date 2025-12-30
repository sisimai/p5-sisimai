use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2007';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '03' => [['5.2.3',   '550', 'emailtoolarge',   0, 0]],
    '04' => [['5.7.1',   '550', 'securityerror',   0, 0]],
    '05' => [['4.4.1',   '',    'expired',         0, 0]],
    '06' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '07' => [['5.1.1',   '550', 'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

