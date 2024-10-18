use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'IMailServer';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.912', '',    'hostunknown',     1]],
    '01002' => [['5.0.922', '',    'mailboxfull',     0]],
    '01003' => [['5.0.911', '',    'userunknown',     1]],
    '01004' => [['5.0.911', '',    'userunknown',     1]],
    '01005' => [['5.0.922', '',    'mailboxfull',     0]],
    '01006' => [['5.0.911', '',    'userunknown',     1]],
    '01007' => [['5.0.911', '',    'userunknown',     1]],
    '01008' => [['5.0.912', '',    'hostunknown',     1]],
    '01009' => [['5.0.947', '',    'expired',         0]],
    '01010' => [['5.0.947', '',    'expired',         0],
                ['5.0.947', '',    'expired',         0]],
    '01011' => [['5.0.911', '',    'userunknown',     1]],
    '01012' => [['5.0.922', '',    'mailboxfull',     0]],
    '01013' => [['5.0.911', '',    'userunknown',     1]],
    '01014' => [['5.0.912', '',    'hostunknown',     1]],
    '01015' => [['5.0.911', '',    'userunknown',     1]],
    '01016' => [['5.0.947', '',    'expired',         0]],
    '01017' => [['5.0.947', '',    'expired',         0]],
    '01018' => [['5.0.922', '',    'mailboxfull',     0]],
    '01019' => [['5.0.922', '',    'mailboxfull',     0]],
    '01020' => [['5.0.901', '',    'onhold',          0]],
    '01021' => [['5.0.922', '',    'mailboxfull',     0]],
    '01022' => [['5.0.911', '',    'userunknown',     1],
                ['5.0.911', '',    'userunknown',     1]],
    '01023' => [['5.0.922', '',    'mailboxfull',     0]],
    '01024' => [['5.0.901', '',    'onhold',          0]],
    '01025' => [['5.0.911', '',    'userunknown',     1]],
    '01026' => [['5.0.911', '',    'userunknown',     1]],
    '01027' => [['5.0.911', '',    'userunknown',     1]],
    '01028' => [['5.0.911', '',    'userunknown',     1]],
    '01029' => [['5.0.911', '',    'userunknown',     1]],
    '01030' => [['5.0.912', '',    'hostunknown',     1]],
    '01031' => [['5.0.912', '',    'hostunknown',     1]],
    '01032' => [['5.0.901', '',    'onhold',          0]],
    '01033' => [['5.0.911', '',    'userunknown',     1]],
    '01034' => [['5.0.911', '',    'userunknown',     1]],
    '01035' => [['5.0.980', '550', 'spamdetected',    0]],
    '01036' => [['5.0.980', '550', 'spamdetected',    0]],
    '01037' => [['5.0.980', '550', 'spamdetected',    0]],
    '01038' => [['5.0.922', '',    'mailboxfull',     0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

