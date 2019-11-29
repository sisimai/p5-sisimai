use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Zoho';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/,     'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]2[.][12]\z/,  'r' => qr/(?:mailboxfull|filtered)/, 'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/filtered/,    'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A4[.]0[.]\d+\z/,   'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A4[.]0[.]\d+\z/,   'r' => qr/expired/,     'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

