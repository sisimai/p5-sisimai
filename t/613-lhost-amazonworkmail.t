use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'AmazonWorkMail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.2.1',   '550', 'filtered',        0]],
    '03' => [['5.3.5',   '550', 'systemerror',     0]],
    '04' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '05' => [['4.4.2',   '421', 'expired',         0]],
    '07' => [['4.4.2',   '421', 'expired',         0]],
    '08' => [['5.2.2',   '550', 'mailboxfull',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

