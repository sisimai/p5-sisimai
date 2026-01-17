use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Office365';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1002'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1003'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1004'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1005'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1006'  => [['5.4.14',  '554', 'networkerror',    0, 0]],
    '1007'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1008'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1009'  => [['5.9.370', '553', 'securityerror',   0, 0]],
    '1010'  => [['5.1.0',   '550', 'authfailure',     0, 0]],
    '1011'  => [['5.1.351', '550', 'filtered',        0, 1]],
    '1012'  => [['5.1.8',   '501', 'rejected',        0, 0]],
    '1013'  => [['5.4.312', '550', 'networkerror',    0, 0]],
    '1014'  => [['5.1.351', '550', 'userunknown',     1, 1]],
    '1015'  => [['5.1.351', '550', 'userunknown',     1, 1]],
    '1016'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1017'  => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '1018'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1019'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1020'  => [['5.1.10',  '550', 'userunknown',     1, 1]],
    '1021'  => [['5.4.14',  '554', 'networkerror',    0, 0]],
    '1022'  => [['5.2.14',  '550', 'systemerror',     0, 0]],
    '1023'  => [['5.4.310', '550', 'norelaying',      0, 1]],
    '1024'  => [['5.4.310', '550', 'norelaying',      0, 1]],
#   '1025'  => [['5.1.10',  '550', 'userunknown',     1, 1]], # TODO:
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

