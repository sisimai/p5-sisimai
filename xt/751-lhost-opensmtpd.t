use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'OpenSMTPD';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'userunknown',     1]],
    '01002' => [['5.2.1',   '550', 'filtered',        0]],
    '01003' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01004' => [['5.0.910', '550', 'filtered',        0]],
    '01005' => [['5.0.910', '550', 'filtered',        0]],
    '01006' => [['5.0.947', '',    'expired',         0]],
    '01007' => [['5.1.1',   '550', 'userunknown',     1]],
    '01008' => [['5.2.2',   '550', 'mailboxfull',     0],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01009' => [['5.0.912', '',    'hostunknown',     1]],
    '01010' => [['5.0.944', '',    'networkerror',    0]],
    '01011' => [['5.1.1',   '550', 'userunknown',     1]],
    '01012' => [['5.2.2',   '550', 'mailboxfull',     0],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01013' => [['5.0.912', '',    'hostunknown',     1]],
    '01014' => [['5.0.947', '',    'expired',         0]],
    '01015' => [['5.0.944', '',    'networkerror',    0]],
    '01016' => [['5.0.912', '',    'hostunknown',     1]],
    '01017' => [['5.7.26',  '550', 'authfailure',     0]],
    '01018' => [['5.0.932', '',    'notaccept',       1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

