use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'Exchange2007';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

