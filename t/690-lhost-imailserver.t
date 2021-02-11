use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'IMailServer';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.911', '',    'userunknown',     1]],
    '02' => [['5.0.922', '',    'mailboxfull',     0]],
    '03' => [['5.0.911', '',    'userunknown',     1]],
    '04' => [['5.0.947', '',    'expired',         0]],
    '06' => [['5.0.980', '550', 'spamdetected',    0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

