use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exim';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.7.0',   '550', 'blocked',         0]],
    '02' => [['5.1.1',   '550', 'userunknown',     1],
             ['5.2.1',   '550', 'userunknown',     1]],
    '03' => [['5.7.0',   '554', 'policyviolation', 0]],
    '04' => [['5.7.0',   '550', 'blocked',         0]],
    '05' => [['5.1.1',   '553', 'userunknown',     1]],
    '06' => [['4.0.947', '',    'expired',         0]],
    '07' => [['4.0.922', '',    'mailboxfull',     0]],
    '08' => [['4.0.947', '',    'expired',         0]],
    '29' => [['5.0.0',   '550', 'authfailure',     0]],
    '30' => [['5.7.1',   '554', 'userunknown',     1]],
    '31' => [['5.0.912', '',    'hostunknown',     1]],
    '32' => [['5.0.971', '571', 'blocked',         0]],
    '33' => [['5.0.971', '554', 'blocked',         0]],
    '34' => [['5.7.1',   '554', 'blocked',         0]],
    '35' => [['5.0.971', '550', 'blocked',         0]],
    '36' => [['5.0.901', '550', 'rejected',        0]],
    '37' => [['5.0.912', '553', 'hostunknown',     1]],
    '38' => [['4.0.901', '450', 'blocked',         0]],
    '39' => [['5.0.971', '550', 'blocked',         0]],
    '40' => [['5.0.901', '551', 'blocked',         0]],
    '41' => [['4.0.901', '450', 'blocked',         0]],
    '42' => [['5.7.1',   '554', 'blocked',         0]],
    '43' => [['5.7.1',   '550', 'rejected',        0]],
    '44' => [['5.0.0',   '',    'mailererror',     0]],
    '45' => [['5.2.0',   '550', 'rejected',        0]],
    '46' => [['5.7.1',   '554', 'blocked',         0]],
    '47' => [['5.0.971', '550', 'blocked',         0]],
    '48' => [['5.7.1',   '550', 'rejected',        0]],
    '49' => [['5.0.0',   '550', 'blocked',         0]],
    '50' => [['5.1.7',   '550', 'rejected',        0]],
    '51' => [['5.1.0',   '553', 'rejected',        0]],
    '52' => [['5.0.902', '',    'syntaxerror',     0]],
    '53' => [['5.0.939', '',    'mailererror',     0]],
    '54' => [['5.0.901', '550', 'blocked',         0]],
    '55' => [['5.7.0',   '554', 'spamdetected',    0]],
    '56' => [['5.0.971', '554', 'blocked',         0]],
    '57' => [['5.0.918', '',    'rejected',        0]],
    '58' => [['5.0.934', '500', 'mesgtoobig',      0]],
    '59' => [['5.1.1',   '550', 'userunknown',     1]],
    '60' => [['5.0.0',   '',    'mailboxfull',     0]],
    '61' => [['5.1.1',   '550', 'userunknown',     1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

