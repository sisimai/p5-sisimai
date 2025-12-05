use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Aol';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '02' => [['5.2.2',   '550', 'mailboxfull',     0, 1]],
    '03' => [['5.2.2',   '550', 'mailboxfull',     0, 1],
             ['5.1.1',   '550', 'userunknown',     1, 1]],
    '04' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '05' => [['5.4.4',   '',    'hostunknown',     1, 1]],
    '06' => [['5.4.4',   '',    'notaccept',       1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

