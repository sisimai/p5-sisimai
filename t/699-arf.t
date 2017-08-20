use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'ARF';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '02', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '03', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '04', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '05', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '06', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '07', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '08', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '09', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '10', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '11', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '12', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/opt-out/,      'b' => qr/\A-1\z/ },
    { 'n' => '13', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '14', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '15', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

