use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'Exchange2003';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/userunknown/ },
    { 'n' => '01002', 'r' => qr/userunknown/ },
    { 'n' => '01003', 'r' => qr/userunknown/ },
    { 'n' => '01004', 'r' => qr/userunknown/ },
    { 'n' => '01005', 'r' => qr/userunknown/ },
    { 'n' => '01006', 'r' => qr/userunknown/ },
    { 'n' => '01007', 'r' => qr/userunknown/ },
    { 'n' => '01008', 'r' => qr/userunknown/ },
    { 'n' => '01009', 'r' => qr/userunknown/ },
    { 'n' => '01010', 'r' => qr/userunknown/ },
    { 'n' => '01011', 'r' => qr/userunknown/ },
    { 'n' => '01012', 'r' => qr/userunknown/ },
    { 'n' => '01013', 'r' => qr/userunknown/ },
    { 'n' => '01014', 'r' => qr/userunknown/ },
    { 'n' => '01015', 'r' => qr/userunknown/ },
    { 'n' => '01016', 'r' => qr/userunknown/ },
    { 'n' => '01017', 'r' => qr/filtered/    },
    { 'n' => '01018', 'r' => qr/userunknown/ },
    { 'n' => '01019', 'r' => qr/userunknown/ },
    { 'n' => '01020', 'r' => qr/userunknown/ },
    { 'n' => '01021', 'r' => qr/userunknown/ },
    { 'n' => '01022', 'r' => qr/userunknown/ },
    { 'n' => '01023', 'r' => qr/filtered/    },
    { 'n' => '01024', 'r' => qr/userunknown/ },
    { 'n' => '01025', 'r' => qr/userunknown/ },
    { 'n' => '01026', 'r' => qr/userunknown/ },
    { 'n' => '01027', 'r' => qr/userunknown/ },
    { 'n' => '01028', 'r' => qr/userunknown/ },
    { 'n' => '01029', 'r' => qr/userunknown/ },
    { 'n' => '01030', 'r' => qr/userunknown/ },
    { 'n' => '01031', 'r' => qr/userunknown/ },
    { 'n' => '01032', 'r' => qr/userunknown/ },
    { 'n' => '01033', 'r' => qr/userunknown/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

