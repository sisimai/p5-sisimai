use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'Aol';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]4[.]4\z/, 'r' => qr/hostunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]2[.]2\z/, 'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.][12][.][12]\z/, 'r' => qr/(?:mailboxfull|userunknown)/, 'b' => qr/\d\z/ },
    { 'n' => '04', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '05', 's' => qr/\A5[.]4[.]4\z/, 'r' => qr/hostunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '06', 's' => qr/\A5[.]4[.]4\z/, 'r' => qr/notaccept/,   'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

