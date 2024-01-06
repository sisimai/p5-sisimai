use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'EinsUndEins';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.922', '',    'mailboxfull',     0]],
    '01002' => [['5.0.922', '',    'mailboxfull',     0]],
    '01003' => [['5.0.934', '',    'mesgtoobig',      0]],
    '01004' => [['5.1.1',   '550', 'userunknown',     1]],
    '01005' => [['5.4.1',   '550', 'userunknown',     1]],
    '01006' => [['5.4.1',   '550', 'userunknown',     1]],
    '01007' => [['5.4.1',   '550', 'userunknown',     1]],
    '01008' => [['5.4.1',   '550', 'userunknown',     1]],
    '01009' => [['5.1.1',   '550', 'userunknown',     1]],
    '01010' => [['5.1.1',   '550', 'userunknown',     1]],
    '01011' => [['5.4.1',   '550', 'userunknown',     1]],
    '01012' => [['5.4.1',   '550', 'userunknown',     1]],
    '01013' => [['5.4.1',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

