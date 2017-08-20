use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'RFC3834';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    { 'n' => '02', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    { 'n' => '03', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    { 'n' => '04', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    { 'n' => '05', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    { 'n' => '06', 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

