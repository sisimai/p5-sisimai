use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MessagingServer';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.4.4',   '',    'hostunknown',     1]],
    '01002' => [['5.0.0',   '',    'mailboxfull',     0]],
    '01003' => [['5.7.1',   '550', 'filtered',        0],
                ['5.7.1',   '550', 'filtered',        0]],
    '01004' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01005' => [['5.4.4',   '',    'hostunknown',     1]],
    '01006' => [['5.7.1',   '550', 'filtered',        0]],
    '01007' => [['5.2.0',   '522', 'mailboxfull',     0]],
    '01008' => [['5.2.1',   '550', 'filtered',        0]],
    '01009' => [['5.0.0',   '',    'mailboxfull',     0]],
    '01010' => [['5.2.0',   '522', 'mailboxfull',     0]],
    '01011' => [['4.4.7',   '',    'expired',         0]],
    '01012' => [['5.0.0',   '550', 'filtered',        0]],
    '01013' => [['4.2.2',   '',    'mailboxfull',     0]],
    '01014' => [['4.2.2',   '',    'mailboxfull',     0]],
    '01015' => [['5.0.0',   '550', 'filtered',        0]],
    '01016' => [['5.0.0',   '550', 'userunknown',     1]],
    '01017' => [['5.0.932', '',    'notaccept',       1]],
    '01018' => [['5.1.8',   '501', 'rejected',        0]],
    '01019' => [['4.2.2',   '',    'mailboxfull',     0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

