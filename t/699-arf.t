use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'ARF';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '02', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '11', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '12', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/opt-out/,      'b' => qr/\A-1\z/ },
    { 'n' => '14', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '15', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '16', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '17', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '18', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '19', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '20', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
    { 'n' => '21', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '22', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '23', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
    { 'n' => '24', 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,        'b' => qr/\A-1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

