use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'qmail';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]5[.]0\z/,    'r' => qr/userunknown/,  'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.][12][.]1\z/, 'r' => qr/(?:userunknown|filtered)/, 'b' => qr/\d\z/ },
    { 'n' => '03', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/rejected/,     'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A5[.]0[.]0\z/,    'r' => qr/blocked/,      'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A4[.]4[.]3\z/,    'r' => qr/systemerror/,  'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A4[.]2[.]2\z/,    'r' => qr/mailboxfull/,  'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A4[.]4[.]1\z/,    'r' => qr/networkerror/, 'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A5[.]0[.]\d+\z/,  'r' => qr/mailboxfull/,  'b' => qr/\A1\z/ },
    { 'n' => '09', 's' => qr/\A5[.]7[.]\d+\z/,  'r' => qr/blocked/,      'b' => qr/\A1\z/ },
    { 'n' => '10', 's' => qr/\A5[.]0[.]\d+\z/,  'r' => qr/suspend/,      'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

