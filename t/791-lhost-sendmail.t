use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Sendmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '02' => [['5.1.1',   '550', 'userunknown',     1],
             ['5.2.1',   '550', 'filtered',        0]],
    '03' => [['5.1.1',   '550', 'userunknown',     1]],
    '04' => [['5.1.8',   '553', 'rejected',        0]],
    '05' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '06' => [['5.6.9',   '550', 'contenterror',    0]],
    '07' => [['5.7.1',   '554', 'norelaying',      0]],
    '08' => [['4.7.1',   '450', 'requireptr',      0]],
    '09' => [['5.7.9',   '554', 'policyviolation', 0]],
    '10' => [['4.7.1',   '450', 'blocked',         0]],
    '11' => [['4.4.7',   '',    'networkerror',    0]],
    '12' => [['4.4.7',   '',    'expired',         0]],
    '13' => [['5.3.0',   '550', 'systemerror',     0]],
    '14' => [['5.1.1',   '550', 'userunknown',     1]],
    '15' => [['5.1.2',   '550', 'hostunknown',     1]],
    '16' => [['5.5.0',   '554', 'blocked',         0]],
    '17' => [['5.1.6',   '551', 'hasmoved',        1]],
    '18' => [['5.3.0',   '554', 'mailererror',     0]],
    '19' => [['5.2.0',   '550', 'filtered',        0]],
    '20' => [['5.4.6',   '554', 'networkerror',    0]],
    '21' => [['4.4.7',   '',    'blocked',         0]],
    '22' => [['5.1.6',   '551', 'hasmoved',        1]],
    '24' => [['5.1.2',   '550', 'hostunknown',     1]],
    '25' => [['5.1.1',   '550', 'userunknown',     1]],
    '26' => [['5.1.1',   '550', 'userunknown',     1]],
    '27' => [['5.0.0',   '550', 'filtered',        0]],
    '28' => [['5.1.1',   '550', 'userunknown',     1]],
    '29' => [['4.5.0',   '421', 'expired',         0]],
    '30' => [['4.4.7',   '421', 'expired',         0]],
    '31' => [['5.7.0',   '552', 'policyviolation', 0],
             ['5.7.0',   '552', 'policyviolation', 0]],
    '32' => [['5.1.1',   '550', 'userunknown',     1]],
    '33' => [['5.7.1',   '550', 'blocked',         0]],
    '34' => [['5.7.0',   '552', 'policyviolation', 0]],
    '35' => [['5.7.13',  '525', 'suspend',         0]],
    '36' => [['5.7.1',   '550', 'blocked',         0]],
    '37' => [['5.1.1',   '550', 'userunknown',     1]],
    '38' => [['5.7.1',   '550', 'spamdetected',    0]],
    '39' => [['4.4.5',   '452', 'systemfull',      0]],
    '40' => [['5.2.0',   '550', 'filtered',        0]],
    '41' => [['5.0.0',   '554', 'userunknown',     1]],
    '42' => [['5.1.2',   '550', 'hostunknown',     1]],
    '43' => [['5.7.1',   '550', 'notcompliantrfc', 0]],
    '44' => [['5.6.0',   '552', 'contenterror',    0]],
    '45' => [['5.1.1',   '550', 'userunknown',     1]],
    '46' => [['5.5.0',   '550', 'userunknown',     1]],
    '47' => [['5.1.1',   '550', 'userunknown',     1]],
    '48' => [['5.7.1',   '550', 'filtered',        0]],
    '49' => [['5.1.1',   '550', 'userunknown',     1]],
    '50' => [['5.2.0',   '550', 'filtered',        0]],
    '51' => [['5.2.0',   '550', 'filtered',        0]],
    '52' => [['5.1.1',   '550', 'userunknown',     1]],
    '53' => [['5.0.0',   '550', 'securityerror',   0]],
    '54' => [['4.4.7',   '',    'expired',         0]],
    '55' => [['4.5.0',   '451', 'mailererror',     0]],
    '56' => [['4.7.0',   '421', 'blocked',         0]],
    '57' => [['5.7.27',  '550', 'notaccept',       1]],
    '58' => [['5.7.1',   '550', 'authfailure',     0]],
    '59' => [['5.7.1',   '550', 'authfailure',     0]],
    '60' => [['5.7.26',  '550', 'authfailure',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;

