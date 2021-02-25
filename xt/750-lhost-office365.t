use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Office365';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.10',  '550', 'userunknown',     1]],
    '01002' => [['5.1.10',  '550', 'userunknown',     1]],
    '01003' => [['5.1.10',  '550', 'userunknown',     1]],
    '01004' => [['5.1.10',  '550', 'userunknown',     1]],
    '01005' => [['5.1.10',  '550', 'userunknown',     1]],
    '01006' => [['5.4.14',  '554', 'networkerror',    0]],
    '01007' => [['5.1.1',   '550', 'userunknown',     1]],
    '01008' => [['5.1.1',   '550', 'userunknown',     1]],
    '01009' => [['5.0.0',   '553', 'securityerror',   0]],
    '01010' => [['5.1.0',   '550', 'blocked',         0]],
    '01011' => [['5.1.351', '550', 'filtered',        0]],
    '01012' => [['5.1.8',   '501', 'rejected',        0]],
    '01013' => [['5.4.312', '550', 'networkerror',    0]],
    '01014' => [['5.1.351', '550', 'userunknown',     1]],
    '01015' => [['5.1.351', '550', 'userunknown',     1]],
    '01016' => [['5.1.1',   '550', 'userunknown',     1]],
    '01017' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01018' => [['5.1.10',  '550', 'userunknown',     1]],
    '01019' => [['5.1.10',  '550', 'userunknown',     1]],
    '01020' => [['5.1.10',  '550', 'userunknown',     1]],
    '01021' => [['5.4.14',  '554', 'networkerror',    0]],
    '01022' => [['5.2.14',  '550', 'systemerror',     0]],
    '01023' => [['5.4.310', '550', 'systemerror',     0]],
    '01024' => [['5.4.310', '550', 'systemerror',     0]],
    '01025' => [['5.1.10',  '550', 'userunknown',     1]],
    '01026' => [['5.1.10',  '550', 'userunknown',     1]],
    '01027' => [['5.1.1',   '550', 'userunknown',     1]],
    '01028' => [['5.1.1',   '550', 'userunknown',     1]],
    '01029' => [['5.1.1',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

