use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'MessagingServer';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/hostunknown/ },
    { 'n' => '01002', 'r' => qr/mailboxfull/ },
    { 'n' => '01003', 'r' => qr/filtered/    },
    { 'n' => '01004', 'r' => qr/mailboxfull/ },
    { 'n' => '01005', 'r' => qr/hostunknown/ },
    { 'n' => '01006', 'r' => qr/filtered/    },
    { 'n' => '01007', 'r' => qr/mailboxfull/ },
    { 'n' => '01008', 'r' => qr/filtered/    },
    { 'n' => '01009', 'r' => qr/mailboxfull/ },
    { 'n' => '01010', 'r' => qr/mailboxfull/ },
    { 'n' => '01011', 'r' => qr/expired/     },
    { 'n' => '01012', 'r' => qr/filtered/    },
    { 'n' => '01013', 'r' => qr/mailboxfull/ },
    { 'n' => '01014', 'r' => qr/mailboxfull/ },
    { 'n' => '01015', 'r' => qr/filtered/    },
    { 'n' => '01016', 'r' => qr/userunknown/ },
    { 'n' => '01017', 'r' => qr/notaccept/   },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

