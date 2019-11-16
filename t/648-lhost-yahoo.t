use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Yahoo';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '04', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A5[.]2[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '06', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/filtered/,  'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '08', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '09', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/notaccept/, 'b' => qr/\A0\z/ },
    { 'n' => '10', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '11', 's' => qr/\A5[.]1[.]8\z/, 'r' => qr/rejected/,    'b' => qr/\A1\z/ },
    { 'n' => '12', 's' => qr/\A5[.]1[.]8\z/, 'r' => qr/rejected/,    'b' => qr/\A1\z/ },
    { 'n' => '13', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/expired/,   'b' => qr/\A1\z/ },
    { 'n' => '14', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/blocked/,   'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;


