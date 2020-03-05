use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'GoogleGroups';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/rejected/ },
    { 'n' => '01002', 'r' => qr/rejected/ },
    { 'n' => '01003', 'r' => qr/rejected/ },
    { 'n' => '01004', 'r' => qr/rejected/ },
    { 'n' => '01005', 'r' => qr/rejected/ },
    { 'n' => '01006', 'r' => qr/rejected/ },
    { 'n' => '01007', 'r' => qr/rejected/ },
    { 'n' => '01008', 'r' => qr/rejected/ },
    { 'n' => '01009', 'r' => qr/rejected/ },
    { 'n' => '01010', 'r' => qr/rejected/ },
    { 'n' => '01011', 'r' => qr/rejected/ },
    { 'n' => '01012', 'r' => qr/rejected/ },
    { 'n' => '01013', 'r' => qr/rejected/ },
    { 'n' => '01014', 'r' => qr/rejected/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

