use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Gmail';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.947', '',    'expired',         0]],
    '01002' => [['5.2.1',   '550', 'suspend',         0]],
    '01003' => [['4.0.947', '',    'expired',         0]],
    '01004' => [['5.0.910', '550', 'filtered',        0]],
    '01005' => [['4.0.947', '',    'expired',         0]],
    '01006' => [['5.0.910', '550', 'filtered',        0]],
    '01007' => [['5.1.1',   '550', 'userunknown',     1]],
    '01008' => [['5.0.947', '',    'expired',         0]],
    '01009' => [['4.0.947', '',    'expired',         0]],
    '01010' => [['5.1.1',   '550', 'userunknown',     1]],
    '01011' => [['4.2.2',   '450', 'mailboxfull',     0]],
    '01012' => [['4.0.947', '',    'expired',         0]],
    '01013' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01014' => [['5.1.1',   '550', 'userunknown',     1]],
    '01015' => [['5.0.910', '550', 'filtered',        0]],
    '01016' => [['5.0.910', '550', 'filtered',        0]],
    '01017' => [['5.0.910', '550', 'filtered',        0]],
    '01018' => [['5.1.1',   '550', 'userunknown',     1]],
    '01019' => [['5.1.1',   '550', 'userunknown',     1]],
    '01020' => [['5.0.911', '550', 'userunknown',     1]],
    '01021' => [['5.0.911', '550', 'userunknown',     1]],
    '01022' => [['5.1.1',   '550', 'userunknown',     1]],
    '01023' => [['5.0.911', '550', 'userunknown',     1]],
    '01024' => [['5.0.0',   '553', 'blocked',         0]],
    '01025' => [['5.7.0',   '554', 'filtered',        0]],
    '01026' => [['5.0.910', '550', 'filtered',        0]],
    '01027' => [['5.7.1',   '550', 'securityerror',   0]],
    '01028' => [['5.0.930', '500', 'systemerror',     0]],
    '01029' => [['5.0.901', '',    'onhold',          0]],
    '01030' => [['5.7.1',   '554', 'blocked',         0]],
    '01031' => [['5.7.1',   '550', 'blocked',         0]],
    '01032' => [['5.0.947', '',    'expired',         0]],
    '01033' => [['5.0.971', '',    'blocked',         0]],
    '01034' => [['4.0.947', '',    'expired',         0]],
    '01035' => [['4.0.947', '',    'expired',         0]],
    '01036' => [['4.0.947', '',    'expired',         0]],
    '01037' => [['5.0.971', '',    'blocked',         0]],
    '01038' => [['5.0.911', '550', 'userunknown',     1]],
    '01039' => [['5.1.1',   '550', 'userunknown',     1]],
    '01040' => [['5.0.947', '',    'expired',         0]],
    '01041' => [['5.1.1',   '550', 'userunknown',     1]],
    '01042' => [['5.1.1',   '550', 'userunknown',     1]],
    '01043' => [['5.0.911', '550', 'userunknown',     1]],
    '01044' => [['5.0.972', '',    'policyviolation', 0]],
    '01045' => [['5.0.947', '',    'expired',         0]],
    '01046' => [['5.1.1',   '550', 'userunknown',     1]],
    '01047' => [['5.1.1',   '550', 'userunknown',     1]],
    '01048' => [['5.0.922', '',    'mailboxfull',     0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

