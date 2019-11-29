use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X5';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

