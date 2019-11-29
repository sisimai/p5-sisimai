use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Courier';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/,   'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]0[.]0\z/, 'r' => qr/filtered/,      'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]7[.]1\z/, 'r' => qr/blocked/,       'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A5[.]0[.]0\z/, 'r' => qr/hostunknown/,   'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

