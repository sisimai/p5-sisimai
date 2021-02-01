use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X4';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.922', '',    'mailboxfull',     0]],
    '01002' => [['5.0.922', '',    'mailboxfull',     0]],
    '01003' => [['5.1.2',   '',    'hostunknown',     1]],
    '01004' => [['5.0.922', '',    'mailboxfull',     0]],
    '01005' => [['5.0.911', '550', 'userunknown',     1]],
    '01006' => [['5.1.1',   '',    'userunknown',     1]],
    '01007' => [['5.0.911', '550', 'userunknown',     1]],
    '01008' => [['5.0.911', '550', 'userunknown',     1]],
    '01009' => [['5.1.1',   '',    'userunknown',     1]],
    '01010' => [['5.1.2',   '',    'hostunknown',     1]],
    '01011' => [['5.1.1',   '550', 'userunknown',     1]],
    '01012' => [['5.0.922', '',    'mailboxfull',     0]],
    '01013' => [['5.0.922', '',    'mailboxfull',     0]],
    '01014' => [['5.0.922', '',    'mailboxfull',     0]],
    '01015' => [['5.0.922', '',    'mailboxfull',     0]],
    '01016' => [['5.0.922', '',    'mailboxfull',     0]],
    '01017' => [['4.4.1',   '',    'networkerror',    0]],
    '01018' => [['5.1.1',   '',    'userunknown',     1]],
    '01019' => [['5.0.911', '550', 'userunknown',     1]],
    '01020' => [['5.0.922', '',    'mailboxfull',     0]],
    '01021' => [['4.4.1',   '',    'networkerror',    0]],
    '01022' => [['5.1.1',   '',    'userunknown',     1]],
    '01023' => [['5.0.922', '',    'mailboxfull',     0]],
    '01024' => [['5.0.922', '',    'mailboxfull',     0]],
    '01025' => [['5.1.1',   '',    'userunknown',     1]],
    '01026' => [['5.0.911', '550', 'userunknown',     1]],
    '01027' => [['5.0.922', '',    'mailboxfull',     0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

