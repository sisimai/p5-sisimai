use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Outlook';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '02', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '03', 's' => qr/\A5[.]5[.]0\z/, 'r' => qr/hostunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '04', 's' => qr/\A5[.][12][.][12]\z/, 'r' => qr/(?:mailboxfull|userunknown)/, 'b' => qr/\A[01]\z/ },
    { 'n' => '06', 's' => qr/\A4[.]4[.]7\z/, 'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A4[.]4[.]7\z/, 'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A5[.]5[.]0\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '09', 's' => qr/\A5[.]5[.]0\z/, 'r' => qr/blocked/,     'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

