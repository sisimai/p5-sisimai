use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Mimecast';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['5.4.1',   '',    'userunknown',     1, 1]],
    '1002'  => [['4.4.4',   '',    'networkerror',    0, 0]],
    '1003'  => [['5.1.1',   '',    'userunknown',     1, 1]],
    '1004'  => [['5.4.14',  '554', 'networkerror',    0, 0]],
    '1005'  => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '1006'  => [['5.7.54',  '550', 'norelaying',      0, 1]],
    '1007'  => [['5.7.1',   '550', 'blocked',         0, 0]],
    '1008'  => [['5.2.1',   '550', 'suspend',         0, 1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

