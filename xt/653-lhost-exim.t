use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exim';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.7.0',   '554', 'policyviolation', 0]],
    '01002' => [['4.0.947', '',    'expired',         0]],
    '01003' => [['5.0.910', '',    'filtered',        0]],
    '01004' => [['5.7.0',   '550', 'blocked',         0]],
    '01005' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.2.1',   '550', 'userunknown',     1]],
    '01006' => [['5.0.910', '',    'filtered',        0]],
    '01007' => [['5.7.0',   '554', 'policyviolation', 0]],
    '01008' => [['5.0.911', '550', 'userunknown',     1]],
    '01009' => [['5.0.912', '',    'hostunknown',     1]],
    '01010' => [['5.7.0',   '550', 'blocked',         0]],
    '01011' => [['5.1.1',   '553', 'userunknown',     1]],
    '01012' => [['5.1.1',   '550', 'userunknown',     1]],
    '01013' => [['5.0.911', '550', 'userunknown',     1]],
    '01014' => [['4.0.947', '',    'expired',         0]],
    '01015' => [['4.0.947', '',    'expired',         0]],
    '01016' => [['5.0.911', '550', 'userunknown',     1]],
    '01017' => [['4.0.947', '',    'expired',         0]],
    '01018' => [['5.0.911', '550', 'userunknown',     1]],
    '01019' => [['5.1.1',   '553', 'userunknown',     1]],
    '01020' => [['5.0.911', '550', 'userunknown',     1]],
    '01022' => [['5.0.911', '550', 'userunknown',     1]],
    '01023' => [['5.2.1',   '550', 'userunknown',     1]],
    '01024' => [['5.0.911', '550', 'userunknown',     1]],
    '01025' => [['5.0.911', '550', 'userunknown',     1]],
    '01026' => [['5.0.911', '550', 'userunknown',     1]],
    '01027' => [['4.0.947', '',    'expired',         0]],
    '01028' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01029' => [['5.0.911', '550', 'userunknown',     1]],
    '01031' => [['4.0.947', '',    'expired',         0]],
    '01032' => [['5.0.911', '550', 'userunknown',     1]],
    '01033' => [['5.0.911', '550', 'userunknown',     1]],
    '01034' => [['5.0.911', '550', 'userunknown',     1]],
    '01035' => [['5.1.8',   '550', 'rejected',        0]],
    '01036' => [['5.0.911', '550', 'userunknown',     1]],
    '01037' => [['4.0.947', '',    'expired',         0]],
    '01038' => [['5.7.0',   '550', 'blocked',         0]],
    '01039' => [['4.0.922', '',    'mailboxfull',     0]],
    '01040' => [['4.0.947', '',    'expired',         0]],
    '01041' => [['4.0.947', '451', 'spamdetected',    0]],
    '01042' => [['5.0.944', '',    'networkerror',    0]],
    '01043' => [['5.0.911', '550', 'userunknown',     1]],
    '01044' => [['5.0.944', '',    'networkerror',    0]],
    '01045' => [['5.0.912', '',    'hostunknown',     1]],
    '01046' => [['5.0.911', '550', 'userunknown',     1]],
    '01047' => [['5.0.911', '550', 'userunknown',     1]],
    '01049' => [['5.0.921', '554', 'suspend',         0]],
    '01050' => [['5.1.1',   '550', 'userunknown',     1]],
    '01051' => [['5.0.911', '550', 'userunknown',     1]],
    '01053' => [['5.0.911', '550', 'userunknown',     1]],
    '01054' => [['5.0.921', '554', 'suspend',         0]],
    '01055' => [['5.0.911', '550', 'userunknown',     1]],
    '01056' => [['5.1.1',   '550', 'userunknown',     1]],
    '01057' => [['5.0.921', '554', 'suspend',         0]],
    '01058' => [['5.1.1',   '550', 'userunknown',     1]],
    '01059' => [['5.0.901', '550', 'onhold',          0]],
    '01060' => [['4.0.947', '',    'expired',         0]],
    '01061' => [['5.0.911', '550', 'userunknown',     1]],
    '01062' => [['5.0.911', '550', 'userunknown',     1]],
    '01063' => [['5.0.911', '550', 'userunknown',     1]],
    '01064' => [['5.0.911', '550', 'userunknown',     1]],
    '01065' => [['5.0.911', '550', 'userunknown',     1]],
    '01066' => [['5.0.911', '550', 'userunknown',     1]],
    '01067' => [['5.0.911', '550', 'userunknown',     1]],
    '01068' => [['5.0.911', '550', 'userunknown',     1]],
    '01069' => [['5.0.911', '550', 'userunknown',     1]],
    '01070' => [['5.0.911', '550', 'userunknown',     1]],
    '01071' => [['5.0.911', '550', 'userunknown',     1]],
    '01072' => [['5.2.1',   '554', 'userunknown',     1]],
    '01073' => [['5.0.921', '554', 'suspend',         0]],
    '01074' => [['5.0.911', '550', 'userunknown',     1]],
    '01075' => [['5.0.911', '550', 'userunknown',     1]],
    '01076' => [['5.0.911', '550', 'userunknown',     1]],
    '01077' => [['5.0.921', '554', 'suspend',         0]],
    '01078' => [['5.0.900', '',    'undefined',       0]],
    '01079' => [['5.0.0',   '',    'hostunknown',     1]],
    '01080' => [['5.0.0',   '',    'hostunknown',     1]],
    '01081' => [['5.0.0',   '',    'hostunknown',     1]],
    '01082' => [['5.0.901', '',    'onhold',          0]],
    '01083' => [['5.0.0',   '',    'onhold',          0]],
    '01084' => [['5.0.0',   '550', 'systemerror',     0]],
    '01085' => [['5.0.0',   '550', 'blocked',         0],
                ['5.0.971', '550', 'blocked',         0]],
    '01086' => [['5.0.0',   '',    'onhold',          0]],
    '01087' => [['5.0.0',   '550', 'onhold',          0]],
    '01088' => [['5.0.901', '550', 'onhold',          0],
                ['5.0.0',   '550', 'onhold',          0]],
    '01089' => [['5.0.0',   '',    'mailererror',     0]],
    '01090' => [['5.0.0',   '',    'onhold',          0]],
    '01091' => [['5.0.0',   '',    'onhold',          0]],
    '01092' => [['5.0.0',   '',    'undefined',       0]],
    '01094' => [['5.0.0',   '',    'onhold',          0]],
    '01095' => [['5.0.0',   '',    'undefined',       0]],
    '01098' => [['4.0.947', '',    'expired',         0],
                ['4.0.947', '',    'expired',         0]],
    '01099' => [['4.0.947', '',    'expired',         0]],
    '01100' => [['5.0.0',   '',    'mailererror',     0]],
    '01101' => [['5.0.0',   '',    'mailererror',     0]],
    '01103' => [['5.0.900', '',    'undefined',       0],
                ['5.0.900', '',    'undefined',       0],
                ['5.0.0',   '',    'undefined',       0]],
    '01104' => [['5.0.0',   '',    'mailererror',     0]],
    '01105' => [['5.0.0',   '',    'mailererror',     0]],
    '01106' => [['5.0.0',   '',    'onhold',          0]],
    '01107' => [['5.0.980', '',    'spamdetected',    0]],
    '01109' => [['5.7.1',   '554', 'userunknown',     1]],
    '01110' => [['5.0.912', '',    'hostunknown',     1],
                ['5.0.912', '',    'hostunknown',     1]],
    '01111' => [['5.0.973', '',    'requireptr',      0]],
    '01112' => [['5.0.973', '554', 'requireptr',      0]],
    '01113' => [['5.7.1',   '554', 'requireptr',      0]],
    '01114' => [['5.0.971', '550', 'blocked',         0]],
    '01115' => [['5.0.901', '550', 'rejected',        0]],
    '01116' => [['5.0.912', '553', 'hostunknown',     1]],
    '01117' => [['4.0.901', '450', 'requireptr',      0]],
    '01118' => [['5.0.973', '550', 'requireptr',      0]],
    '01119' => [['5.0.901', '551', 'requireptr',      0]],
    '01120' => [['4.0.901', '450', 'requireptr',      0]],
    '01121' => [['5.7.1',   '554', 'requireptr',      0]],
    '01122' => [['5.7.1',   '550', 'requireptr',      0]],
    '01123' => [['5.0.0',   '',    'mailererror',     0]],
    '01124' => [['5.2.0',   '550', 'rejected',        0]],
    '01125' => [['5.7.1',   '554', 'blocked',         0]],
    '01126' => [['5.0.971', '550', 'blocked',         0]],
    '01127' => [['5.7.1',   '550', 'requireptr',      0]],
    '01128' => [['5.0.0',   '550', 'blocked',         0]],
    '01129' => [['5.1.7',   '550', 'rejected',        0]],
    '01130' => [['5.1.0',   '553', 'rejected',        0]],
    '01131' => [['5.0.902', '',    'syntaxerror',     0]],
    '01132' => [['5.0.939', '',    'mailererror',     0]],
    '01133' => [['5.0.901', '550', 'blocked',         0]],
    '01134' => [['5.7.0',   '554', 'spamdetected',    0]],
    '01135' => [['5.0.971', '554', 'blocked',         0]],
    '01136' => [['5.0.918', '',    'rejected',        0]],
    '01137' => [['5.0.911', '550', 'userunknown',     1]],
    '01138' => [['5.0.901', '550', 'blocked',         0]],
    '01139' => [['5.0.918', '550', 'rejected',        0]],
    '01140' => [['5.0.945', '',    'toomanyconn',     0]],
    '01141' => [['5.0.910', '',    'filtered',        0]],
    '01142' => [['5.0.971', '',    'virusdetected',   0]],
    '01143' => [['5.0.911', '550', 'userunknown',     1]],
    '01145' => [['5.0.934', '500', 'mesgtoobig',      0]],
    '01146' => [['5.0.911', '550', 'userunknown',     1]],
    '01147' => [['5.0.901', '551', 'blocked',         0]],
    '01148' => [['5.0.980', '550', 'spamdetected',    0]],
    '01149' => [['5.0.901', '550', 'rejected',        0]],
    '01150' => [['5.7.1',   '553', 'blocked',         0]],
    '01151' => [['5.0.0',   '550', 'suspend',         0]],
    '01152' => [['5.0.0',   '550', 'blocked',         0]],
    '01153' => [['5.0.0',   '550', 'blocked',         0]],
    '01154' => [['5.7.1',   '553', 'blocked',         0]],
    '01155' => [['5.0.0',   '550', 'blocked',         0]],
    '01156' => [['5.0.0',   '550', 'blocked',         0]],
    '01157' => [['5.0.0',   '',    'spamdetected',    0]],
    '01158' => [['5.0.0',   '',    'filtered',        0]],
    '01159' => [['5.0.0',   '',    'spamdetected',    0]],
    '01161' => [['5.3.4',   '552', 'mesgtoobig',      0],
                ['5.3.4',   '552', 'mesgtoobig',      0],
                ['5.3.4',   '552', 'mesgtoobig',      0],
                ['5.3.4',   '552', 'mesgtoobig',      0]],
    '01162' => [['5.7.1',   '550', 'requireptr',      0]],
    '01163' => [['5.1.1',   '550', 'mailboxfull',     0]],
    '01164' => [['5.7.1',   '553', 'authfailure',     0]],
    '01165' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01168' => [['4.0.947', '',    'expired',         0]],
    '01169' => [['5.4.3',   '',    'systemerror',     0]],
    '01170' => [['5.0.0',   '',    'systemerror',     0]],
    '01171' => [['5.0.0',   '',    'mailboxfull',     0]],
    '01172' => [['5.0.0',   '',    'hostunknown',     1]],
    '01173' => [['5.0.0',   '',    'networkerror',    0]],
    '01175' => [['5.0.0',   '',    'expired',         0]],
    '01176' => [['5.0.0',   '550', 'userunknown',     1]],
    '01177' => [['5.0.0',   '',    'filtered',        0]],
    '01178' => [['4.0.947', '',    'expired',         0]],
    '01179' => [['5.0.0',   '',    'mailererror',     0]],
    '01181' => [['5.0.0',   '',    'mailererror',     0],
                ['5.0.939', '',    'mailererror',     0]],
    '01182' => [['5.1.1',   '550', 'userunknown',     1]],
    '01183' => [['5.0.0',   '',    'mailboxfull',     0]],
    '01184' => [['5.1.1',   '550', 'userunknown',     1]],
    '01185' => [['5.0.0',   '554', 'suspend',         0]],
    '01186' => [['5.0.0',   '550', 'userunknown',     1]],
    '01187' => [['5.0.0',   '',    'hostunknown',     1]],
    '01188' => [['5.2.0',   '550', 'spamdetected',    0]],
    '01189' => [['5.0.0',   '',    'expired',         0]],
    '01190' => [['5.0.0',   '',    'hostunknown',     1]],
    '01191' => [['5.0.0',   '550', 'suspend',         0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

