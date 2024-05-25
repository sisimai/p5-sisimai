use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3464';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '',    'mailboxfull',     0]],
    '03' => [['5.0.0',   '554', 'policyviolation', 0]],
    '04' => [['5.5.0',   '554', 'mailererror',     0]],
    '06' => [['5.5.0',   '',    'userunknown',     1]],
    '07' => [['4.4.0',   '',    'expired',         0]],
    '08' => [['5.7.1',   '550', 'spamdetected',    0]],
    '09' => [['4.3.0',   '',    'mailboxfull',     0]],
    '10' => [['5.1.6',   '550', 'hasmoved',        1]],
    '26' => [['5.1.1',   '550', 'userunknown',     1]],
    '28' => [['2.1.5',   '250', 'delivered',       0],
             ['2.1.5',   '250', 'delivered',       0]],
    '29' => [['5.5.0',   '503', 'syntaxerror',     0]],
    '34' => [['4.4.1',   '',    'networkerror',    0]],
    '35' => [['5.0.0',   '550', 'rejected',        0],
             ['4.0.0',   '',    'expired',         0],
             ['5.0.0',   '550', 'filtered',        0]],
    '36' => [['4.0.0',   ''   , 'expired',         0]],
    '37' => [['5.0.912', '',    'hostunknown',     1]],
    '38' => [['5.0.922', '',    'mailboxfull',     0]],
    '39' => [['5.0.901', '',    'onhold',          0]],
    '40' => [['4.4.6',   '',    'networkerror',    0]],
    '42' => [['5.0.0',   '',    'filtered',        0]],
    '43' => [['4.3.0',   '451', 'onhold',          0]],
};
$enginetest->($enginename, $isexpected);

is Sisimai::RFC3464->inquire({}), undef;
is Sisimai::RFC3464->inquire({'neko' => 2}, []), undef;

done_testing;

