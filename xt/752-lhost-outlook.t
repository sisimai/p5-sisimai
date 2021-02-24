use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Outlook';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01002' => [['5.5.0',   '550', 'userunknown',     1]],
    '01003' => [['5.5.0',   '550', 'userunknown',     1]],
    '01007' => [['5.5.0',   '550', 'blocked',         0]],
    '01008' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01016' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01017' => [['5.1.1',   '550', 'userunknown',     1]],
    '01018' => [['5.5.0',   '554', 'hostunknown',     1]],
    '01019' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.2.2',   '550', 'mailboxfull',     0]],
    '01023' => [['5.1.1',   '550', 'userunknown',     1]],
    '01024' => [['5.1.1',   '550', 'userunknown',     1]],
    '01025' => [['5.5.0',   '550', 'filtered',        0]],
    '01026' => [['5.5.0',   '550', 'filtered',        0]],
    '01027' => [['5.5.0',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

