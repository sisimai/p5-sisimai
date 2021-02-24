use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Gmail';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
    '03' => [['5.7.0',   '554', 'filtered',        0]],
    '04' => [['5.7.1',   '554', 'blocked',         0]],
    '05' => [['5.7.1',   '550', 'securityerror',   0]],
    '06' => [['4.2.2',   '450', 'mailboxfull',     0]],
    '07' => [['5.0.930', '500', 'systemerror',     0]],
    '08' => [['5.0.947', '',    'expired',         0]],
    '09' => [['4.0.947', '',    'expired',         0]],
    '10' => [['5.0.947', '',    'expired',         0]],
    '11' => [['5.0.947', '',    'expired',         0]],
    '15' => [['5.0.947', '',    'expired',         0]],
    '16' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '17' => [['4.0.947', '',    'expired',         0]],
    '18' => [['5.1.1',   '550', 'userunknown',     1]],
    '19' => [['5.0.922', '',    'mailboxfull',     0]],
};

$enginetest->($enginename, $isexpected);
done_testing;


