use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'MessageLabs';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/userunknown/   },
    { 'n' => '01002', 'r' => qr/securityerror/ },
    { 'n' => '01003', 'r' => qr/userunknown/   },
    { 'n' => '01004', 'r' => qr/userunknown/   },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

