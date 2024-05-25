use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ARF';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'feedback-type'], [...]]
    '01' => [['', '', 'feedback', 0, 'abuse'       ]],
    '02' => [['', '', 'feedback', 0, 'abuse'       ]],
    '11' => [['', '', 'feedback', 0, 'abuse'       ]],
    '12' => [['', '', 'feedback', 0, 'opt-out'     ]],
    '14' => [['', '', 'feedback', 0, 'abuse'       ]],
    '15' => [['', '', 'feedback', 0, 'abuse'       ]],
    '16' => [['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ]],
    '17' => [['', '', 'feedback', 0, 'abuse'       ],
             ['', '', 'feedback', 0, 'abuse'       ]],
    '18' => [['', '', 'feedback', 0, 'auth-failure']],
    '19' => [['', '', 'feedback', 0, 'auth-failure']],
    '20' => [['', '', 'feedback', 0, 'auth-failure']],
    '21' => [['', '', 'feedback', 0, 'abuse'       ]],
    '22' => [['', '', 'feedback', 0, 'abuse'       ]],
    '23' => [['', '', 'feedback', 0, 'abuse'       ]],
    '24' => [['', '', 'feedback', 0, 'abuse'       ]],
    '25' => [['', '', 'feedback', 0, 'abuse'       ]],
    '26' => [['', '', 'feedback', 0, 'opt-out'     ]],
};

$enginetest->($enginename, $isexpected);
is Sisimai::ARF->is_arf(), 0, 'Sisimai::ARF->is_arf() returns 0';
done_testing;

