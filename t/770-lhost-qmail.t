use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'qmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.5.0',   '550', 'userunknown',     1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1],
             ['5.2.1',   '550', 'userunknown',     1]],
    '03' => [['5.7.1',   '550', 'rejected',        0]],
    '04' => [['5.0.0',   '501', 'blocked',         0]],
    '05' => [['4.4.3',   '',    'systemerror',     0]],
    '06' => [['4.2.2',   '450', 'mailboxfull',     0]],
    '07' => [['4.4.1',   '',    'networkerror',    0]],
    '08' => [['5.0.922', '552', 'mailboxfull',     0]],
    '09' => [['5.7.606', '550', 'blocked',         0]],
    '10' => [['5.0.921', '',    'suspend',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

