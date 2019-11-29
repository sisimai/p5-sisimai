use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3834';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01002', 'r' => qr/vacation/ },
    { 'n' => '01003', 'r' => qr/vacation/ },
    { 'n' => '01004', 'r' => qr/vacation/ },
    { 'n' => '01005', 'r' => qr/vacation/ },
    { 'n' => '01006', 'r' => qr/vacation/ },
    { 'n' => '01007', 'r' => qr/vacation/ },
    { 'n' => '01008', 'r' => qr/vacation/ },
    { 'n' => '01009', 'r' => qr/vacation/ },
    { 'n' => '01010', 'r' => qr/vacation/ },
    { 'n' => '01011', 'r' => qr/vacation/ },
    { 'n' => '01012', 'r' => qr/vacation/ },
    { 'n' => '01013', 'r' => qr/vacation/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

