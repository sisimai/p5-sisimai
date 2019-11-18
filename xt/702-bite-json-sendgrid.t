use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './xt/120-obsoleted-bite-json-code';

my $enginename = 'SendGrid';
my $samplepath = sprintf("./set-of-emails/private/json-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/(?:userunknown|filtered|mailboxfull)/ },
    { 'n' => '01002', 'r' => qr/(?:mailboxfull|filtered)/ },
    { 'n' => '01003', 'r' => qr/userunknown/    },
    { 'n' => '01004', 'r' => qr/filtered/       },
    { 'n' => '01005', 'r' => qr/filtered/       },
    { 'n' => '01006', 'r' => qr/userunknown/    },
    { 'n' => '01007', 'r' => qr/filtered/       },
    { 'n' => '01008', 'r' => qr/userunknown/    },
    { 'n' => '01009', 'r' => qr/userunknown/    },
    { 'n' => '01010', 'r' => qr/userunknown/    },
    { 'n' => '01011', 'r' => qr/hostunknown/    },
];

plan 'skip_all', sprintf("No private sample", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

