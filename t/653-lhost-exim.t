use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exim';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.7.0',   '550', 'blocked',         0, 0]],
    '02' => [['5.1.1',   '550', 'userunknown',     1, 1],
             ['5.2.1',   '550', 'userunknown',     1, 1]],
    '03' => [['5.7.0',   '554', 'contenterror',    0, 0]],
    '04' => [['5.7.0',   '550', 'blocked',         0, 0]],
    '05' => [['5.1.1',   '553', 'userunknown',     1, 1]],
    '06' => [['4.9.340', '',    'expired',         0, 0]],
    '07' => [['4.9.220', '',    'mailboxfull',     0, 0]],
    '08' => [['4.9.340', '',    'expired',         0, 0]],
    '29' => [['5.0.0',   '550', 'authfailure',     0, 0]],
    '30' => [['5.7.1',   '554', 'userunknown',     1, 1]],
    '31' => [['5.9.212', '',    'hostunknown',     1, 1]],
    '32' => [['5.9.133', '',    'requireptr',      0, 0]],
    '33' => [['5.9.133', '554', 'requireptr',      0, 0]],
    '34' => [['5.7.1',   '554', 'requireptr',      0, 0]],
    '35' => [['5.9.134', '550', 'blocked',         0, 0]],
    '36' => [['5.9.110', '550', 'rejected',        0, 0]],
    '37' => [['5.9.110', '553', 'rejected',        0, 0]],
    '38' => [['4.9.133', '450', 'requireptr',      0, 0]],
    '39' => [['5.9.133', '550', 'requireptr',      0, 0]],
    '40' => [['5.9.133', '551', 'requireptr',      0, 0]],
    '41' => [['4.9.133', '450', 'requireptr',      0, 0]],
    '42' => [['5.7.1',   '554', 'requireptr',      0, 0]],
    '43' => [['5.7.1',   '550', 'requireptr',      0, 0]],
    '44' => [['5.0.0',   '',    'mailererror',     0, 0]],
    '45' => [['5.2.0',   '550', 'rejected',        0, 0]],
    '46' => [['5.7.1',   '554', 'requireptr',      0, 0]],
    '47' => [['5.9.134', '550', 'blocked',         0, 0]],
    '48' => [['5.7.1',   '550', 'requireptr',      0, 0]],
    '49' => [['5.0.0',   '550', 'blocked',         0, 0]],
    '50' => [['5.1.7',   '550', 'rejected',        0, 0]],
    '51' => [['5.1.0',   '553', 'rejected',        0, 0]],
    '52' => [['5.9.351', '',    'syntaxerror',     0, 0]],
    '53' => [['5.9.230', '',    'mailererror',     0, 0]],
    '54' => [['5.9.134', '550', 'blocked',         0, 0]],
    '55' => [['5.7.0',   '554', 'spamdetected',    0, 0]],
    '56' => [['5.9.134', '554', 'blocked',         0, 0]],
    '57' => [['5.9.110', '',    'rejected',        0, 0]],
    '58' => [['5.9.161', '500', 'emailtoolarge',   0, 0]],
    '59' => [['5.1.1',   '550', 'userunknown',     1, 1]],
    '60' => [['5.0.0',   '',    'mailboxfull',     0, 1]],
    '61' => [['5.1.1',   '550', 'userunknown',     1, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

