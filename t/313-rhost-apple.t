use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Apple';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.6',   '550', 'hasmoved',        1]],
    '02' => [['5.7.1',   '554', 'authfailure',     0]],
    '03' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '04' => [['5.1.1',   '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

