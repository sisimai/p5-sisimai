use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'V5sendmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.0.947', '',    'expired',         0]],
    '02' => [['5.0.912', '550', 'hostunknown',     1]],
    '03' => [['5.0.911', '550', 'userunknown',     1]],
    '04' => [['5.0.912', '550', 'hostunknown',     1],
             ['5.0.912', '550', 'hostunknown',     1]],
    '05' => [['5.0.971', '550', 'blocked',         0],
             ['5.0.912', '550', 'hostunknown',     1],
             ['5.0.912', '550', 'hostunknown',     1],
             ['5.0.911', '550', 'userunknown',     1]],
    '06' => [['5.0.909', '550', 'norelaying',      0]],
    '07' => [['5.0.971', '501', 'blocked',         0],
             ['5.0.912', '550', 'hostunknown',     1],
             ['5.0.911', '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

