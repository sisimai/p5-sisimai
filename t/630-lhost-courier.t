use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Courier';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.0.0',   '550', 'filtered',        0]],
    '03' => [['5.7.1',   '550', 'blocked',         0]],
    '04' => [['5.0.0',   '',    'hostunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

