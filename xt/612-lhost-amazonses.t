use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'AmazonSES';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01002' => [['5.2.1',   '550', 'filtered',        0]],
    '01003' => [['5.1.1',   '550', 'userunknown',     1]],
    '01004' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01005' => [['5.7.1',   '550', 'securityerror',   0]],
    '01006' => [['5.1.1',   '550', 'userunknown',     1]],
    '01007' => [['5.4.7',   '',    'expired',         0]],
    '01008' => [['5.1.2',   '',    'hostunknown',     1]],
    '01009' => [['5.1.0',   '550', 'userunknown',     1]],
    '01010' => [['5.1.0',   '550', 'userunknown',     1]],
    '01011' => [['5.1.0',   '550', 'userunknown',     1]],
    '01012' => [['5.1.0',   '550', 'userunknown',     1]],
    '01013' => [['5.1.0',   '550', 'userunknown',     1]],
    '01014' => [['5.3.0',   '550', 'filtered',        0]],
    '01015' => [['5.1.1',   '550', 'userunknown',     1]],
    '01016' => [['',        '',    'feedback',        0, 'abuse']],
    '01017' => [['2.6.0',   '250', 'delivered',       0]],
    '01018' => [['2.6.0',   '250', 'delivered',       0]],
    '01019' => [['5.7.1',   '554', 'blocked',         0]],
    '01020' => [['4.4.7',   '',    'expired',         0]],
    '01021' => [['5.4.4',   '550', 'hostunknown',     1]],
    '01022' => [['5.5.1',   '550', 'blocked',         0]],
    '01023' => [['5.7.1',   '550', 'suspend',         0]],
    '01024' => [['5.4.1',   '550', 'filtered',        0]],
    '01025' => [['5.2.1',   '550', 'suspend',         0]],
    '01026' => [['5.7.1',   '554', 'norelaying',      0]],
    '01027' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01028' => [['5.4.7',   '',    'expired',         0]],
    '01029' => [['5.3.0',   '550', 'filtered',        0]],
    '01030' => [['2.6.0',   '250', 'delivered',       0]],
    '01031' => [['2.6.0',   '250', 'delivered',       0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

