use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'EZweb';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/filtered/,      'b' => qr/\A1\z/ },
    { 'n' => '02', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/suspend/,       'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/suspend/,       'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/userunknown/,   'b' => qr/\A0\z/ },
    { 'n' => '05', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/expired/,       'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/userunknown/,   'b' => qr/\A0\z/},
    { 'n' => '08', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/blocked/,       'b' => qr/\A1\z/},
];

$enginetest->($enginename, $isexpected);
done_testing;

