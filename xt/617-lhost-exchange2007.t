use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2007';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/userunknown/ },
    { 'n' => '01002', 'r' => qr/mesgtoobig/  },
    { 'n' => '01003', 'r' => qr/userunknown/ },
    { 'n' => '01004', 'r' => qr/userunknown/ },
    { 'n' => '01005', 'r' => qr/mailboxfull/ },
    { 'n' => '01006', 'r' => qr/mesgtoobig/  },
    { 'n' => '01007', 'r' => qr/mailboxfull/ },
    { 'n' => '01008', 'r' => qr/securityerror/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

