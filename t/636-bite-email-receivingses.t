use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'ReceivingSES';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/filtered/,    'b' => qr/\A1\z/ },
    { 'n' => '02', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/filtered/,    'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A4[.]0[.]0\z/, 'r' => qr/onhold/,      'b' => qr/\d\z/ },
    { 'n' => '04', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A5[.]3[.]4\z/, 'r' => qr/mesgtoobig/,  'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]6[.]1\z/, 'r' => qr/contenterror/,'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A5[.]2[.]0\z/, 'r' => qr/filtered/,    'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

