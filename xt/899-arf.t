use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ARF';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '1001'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1002'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1003'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1004'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1005'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1006'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1007'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
#   '1008'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1009'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1010'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1011'  => [['', '', 'feedback', 0, 1, 'opt-out'     ]],
    '1012'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
#   '1013'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
#   '1014'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1015'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
    '1016'  => [['', '', 'feedback', 0, 0, 'auth-failure']],
#   '1017'  => [['', '', 'feedback', 0, 1, 'abuse'       ]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

