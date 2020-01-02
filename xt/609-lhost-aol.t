use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Aol';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/hostunknown/ },
    { 'n' => '01002', 'r' => qr/mailboxfull/ },
    { 'n' => '01003', 'r' => qr/(?:mailboxfull|userunknown)/ },
    { 'n' => '01004', 'r' => qr/(?:mailboxfull|userunknown)/ },
    { 'n' => '01005', 'r' => qr/userunknown/     },
    { 'n' => '01006', 'r' => qr/userunknown/     },
    { 'n' => '01007', 'r' => qr/mailboxfull/     },
    { 'n' => '01008', 'r' => qr/filtered/        },
    { 'n' => '01009', 'r' => qr/policyviolation/ },
    { 'n' => '01010', 'r' => qr/filtered/        },
    { 'n' => '01011', 'r' => qr/filtered/        },
    { 'n' => '01012', 'r' => qr/mailboxfull/     },
    { 'n' => '01013', 'r' => qr/mailboxfull/     },
    { 'n' => '01014', 'r' => qr/userunknown/     },
    { 'n' => '01015', 'r' => qr/userunknown/     },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

