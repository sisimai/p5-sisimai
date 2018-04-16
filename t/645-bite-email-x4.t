use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'X4';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '08', 's' => qr/\A4[.]4[.]1\z/,  'r' => qr/networkerror/, 'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

