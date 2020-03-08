use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Exchange2007';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]2[.]3\z/, 'r' => qr/mesgtoobig/,  'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A5[.]7[.]1\z/, 'r' => qr/securityerror/, 'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A4[.]4[.]1\z/, 'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '07', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

