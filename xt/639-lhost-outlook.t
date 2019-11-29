use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Outlook';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01002', 'r' => qr/userunknown/ },
    { 'n' => '01003', 'r' => qr/userunknown/ },
    { 'n' => '01007', 'r' => qr/blocked/     },
    { 'n' => '01008', 'r' => qr/mailboxfull/ },
    { 'n' => '01016', 'r' => qr/mailboxfull/ },
    { 'n' => '01017', 'r' => qr/userunknown/ },
    { 'n' => '01018', 'r' => qr/hostunknown/ },
    { 'n' => '01019', 'r' => qr/(?:userunknown|mailboxfull)/ },
    { 'n' => '01023', 'r' => qr/userunknown/ },
    { 'n' => '01024', 'r' => qr/userunknown/ },
    { 'n' => '01025', 'r' => qr/filtered/    },
    { 'n' => '01026', 'r' => qr/filtered/    },
    { 'n' => '01027', 'r' => qr/userunknown/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

