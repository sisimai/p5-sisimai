use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Google';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.2.1',   '550', 'suspend',         0]],
    '02' => [['5.1.1',   '550', 'userunknown',     1]],
    '03' => [['5.7.26',  '550', 'authfailure',     0]],
    '04' => [['5.7.26',  '550', 'authfailure',     0]],
    '05' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '06' => [['5.7.25',  '550', 'requireptr',      0]],
    '07' => [['5.2.1',   '550', 'suspend',         0]],
    '08' => [['5.7.1',   '550', 'notcompliantrfc', 0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

