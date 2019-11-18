use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ARF';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/feedback/ },
    { 'n' => '01002', 'r' => qr/feedback/ },
    { 'n' => '01003', 'r' => qr/feedback/ },
    { 'n' => '01004', 'r' => qr/feedback/ },
    { 'n' => '01005', 'r' => qr/feedback/ },
    { 'n' => '01006', 'r' => qr/feedback/ },
    { 'n' => '01007', 'r' => qr/feedback/ },
    { 'n' => '01008', 'r' => qr/feedback/ },
    { 'n' => '01009', 'r' => qr/feedback/ },
    { 'n' => '01010', 'r' => qr/feedback/ },
    { 'n' => '01011', 'r' => qr/feedback/ },
    { 'n' => '01012', 'r' => qr/feedback/ },
    { 'n' => '01013', 'r' => qr/feedback/ },
    { 'n' => '01014', 'r' => qr/feedback/ },
    { 'n' => '01015', 'r' => qr/feedback/ },
    { 'n' => '01016', 'r' => qr/feedback/ },
    { 'n' => '01017', 'r' => qr/feedback/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

