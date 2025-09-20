use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3464';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'mailboxfull',     0]],
    '03' => [['5.0.0',   '554', 'policyviolation', 0]],
    '04' => [['5.5.0',   '554', 'systemerror',     0]],
    '06' => [['5.5.0',   '554', 'userunknown',     1]],
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
             ['4.0.0',   '',    'networkerror',    0],
             ['5.0.0',   '550', 'filtered',        0]],
    '36' => [['4.0.0',   ''   , 'expired',         0]],
    '40' => [['4.4.6',   '',    'networkerror',    0]],
    '42' => [['5.0.0',   '',    'filtered',        0]],
    '43' => [['4.3.0',   '451', 'systemerror',     0]],
    '51' => [['5.1.0',   '550', 'userunknown',     1]],
    '52' => [['4.0.0',   '',    'notaccept',       0]],
    '53' => [['4.0.0',   '',    'networkerror',    0]],
    '54' => [['4.0.0',   '',    'networkerror',    0]],
    '55' => [['4.4.1',   '',    'expired',         0]],
    '56' => [['4.4.1',   '',    'expired',         0]],
    '57' => [['5.0.0',   '550', 'filtered',        0]],
    '58' => [['5.0.0',   '550', 'userunknown',     1]],
    '59' => [['4.0.0',   '',    'notaccept',       0]],
    '60' => [['5.1.8',   '501', 'rejected',        0]],
    '61' => [['5.0.0',   '',    'spamdetected',    0]],
    '62' => [['4.0.0',   '',    'networkerror',    0]],
    '63' => [['5.1.1',   '550', 'userunknown',     1]],
    '64' => [['4.0.0',   '',    'networkerror',    0]],
    '65' => [['5.0.0',   '',    'userunknown',     1]],
};
$enginetest->($enginename, $isexpected);

is Sisimai::RFC3464->inquire({}), undef;
is Sisimai::RFC3464->inquire({'neko' => 2}, []), undef;

done_testing;

