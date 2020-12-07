use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2007';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'userunknown',     1]],
    '01002' => [['5.2.3',   '550', 'mesgtoobig',      0]],
    '01003' => [['5.1.1',   '550', 'userunknown',     1]],
    '01004' => [['5.1.1',   '550', 'userunknown',     1]],
    '01005' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01006' => [['5.2.3',   '550', 'mesgtoobig',      0]],
    '01007' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01008' => [['5.7.1',   '550', 'securityerror',   0]],
    '01009' => [['5.1.1',   '550', 'userunknown',     1]],
    '01010' => [['5.1.1',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

