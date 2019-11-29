use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X4';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]0[.]\d+\z/,'r' => qr/mailboxfull/,  'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A4[.]4[.]1\z/,  'r' => qr/networkerror/, 'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

