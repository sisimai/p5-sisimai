use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Yahoo';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'userunknown',     1]],
    '01002' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01003' => [['5.2.1',   '550', 'userunknown',     1]],
    '01004' => [['5.1.1',   '550', 'userunknown',     1]],
    '01005' => [['5.0.971', '554', 'blocked',         0]],
    '01006' => [['5.0.911', '550', 'userunknown',     1]],
    '01007' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01008' => [['5.0.932', '',    'notaccept',       1]],
    '01009' => [['5.1.1',   '550', 'userunknown',     1]],
    '01010' => [['5.1.8',   '501', 'rejected',        0]],
    '01011' => [['5.0.971', '554', 'blocked',         0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

