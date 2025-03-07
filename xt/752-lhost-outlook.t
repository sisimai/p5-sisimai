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
    '1002'  => [['5.5.0',   '550', 'userunknown',     1]],
    '1003'  => [['5.5.0',   '550', 'userunknown',     1]],
    '1007'  => [['5.5.0',   '550', 'requireptr',      0]],
    '1008'  => [['5.2.2',   '552', 'mailboxfull',     0]],
    '1016'  => [['5.2.2',   '550', 'mailboxfull',     0]],
    '1017'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1018'  => [['5.5.0',   '554', 'hostunknown',     1]],
    '1019'  => [['5.1.1',   '550', 'userunknown',     1],
                ['5.2.2',   '550', 'mailboxfull',     0]],
    '1023'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1024'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1025'  => [['5.5.0',   '550', 'userunknown',     1]],
    '1026'  => [['5.5.0',   '550', 'userunknown',     1]],
    '1027'  => [['5.5.0',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

