use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Outlook';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '02' => [['5.1.1',   '550', 'userunknown',     1]],
    '03' => [['5.5.0',   '554', 'hostunknown',     1]],
    '04' => [['5.1.1',   '550', 'userunknown',     1],
             ['5.2.2',   '550', 'mailboxfull',     0]],
    '06' => [['4.4.7',   '',    'expired',         0]],
    '07' => [['4.4.7',   '',    'expired',         0]],
    '08' => [['5.5.0',   '550', 'userunknown',     1]],
    '09' => [['5.5.0',   '550', 'requireptr',      0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

