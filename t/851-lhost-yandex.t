use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Yandex';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.2.1',   '550', 'userunknown',     1],
             ['5.2.2',   '550', 'mailboxfull',     0]],
    '03' => [['4.4.1',   '',    'expired',         0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

