use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ARF';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01002' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01003' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01004' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01005' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01006' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01007' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01008' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01009' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01010' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01011' => [['', '', 'feedback', 0, 'opt-out'     ]],
    '01012' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01013' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01014' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01015' => [['', '', 'feedback', 0, 'abuse'       ]],
    '01016' => [['', '', 'feedback', 0, 'auth-failure']],
    '01017' => [['', '', 'feedback', 0, 'abuse'       ]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

