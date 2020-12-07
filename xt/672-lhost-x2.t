use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X2';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.7.1',   '554', 'norelaying',      0]],
    '01002' => [['5.0.910', '',    'filtered',        0]],
    '01003' => [['5.0.910', '',    'filtered',        0]],
    '01004' => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '01005' => [['5.0.947', '',    'expired',         0]],
    '01006' => [['5.1.2',   '',    'hostunknown',     1]],
    '01007' => [['5.0.947', '',    'expired',         0]],
    '01008' => [['4.4.1',   '',    'expired',         0]],
    '01009' => [['5.0.922', '',    'mailboxfull',     0]],
    '01010' => [['5.0.921', '',    'suspend',         0]],
    '01011' => [['5.0.922', '',    'mailboxfull',     0],
                ['5.0.922', '',    'mailboxfull',     0]],
    '01012' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01013' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01014' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01015' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01016' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01017' => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '01018' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01019' => [['5.0.922', '',    'mailboxfull',     0]],
    '01020' => [['5.0.910', '',    'filtered',        0]],
    '01021' => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '01022' => [['5.0.910', '',    'filtered',        0]],
    '01023' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01024' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01025' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01026' => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '01027' => [['5.0.922', '',    'mailboxfull',     0],
                ['5.0.922', '',    'mailboxfull',     0]],
    '01028' => [['4.4.1',   '',    'expired',         0]],
    '01029' => [['4.1.9',   '',    'expired',         0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

