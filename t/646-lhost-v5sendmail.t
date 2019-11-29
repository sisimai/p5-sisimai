use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'V5sendmail';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '02', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/hostunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '03', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '04', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/hostunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '05', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/(?:hostunknown|blocked|userunknown)/, 'b' => qr/\d\z/ },
    { 'n' => '06', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/norelaying/,  'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A5[.]0[.]\d+\z/, 'r' => qr/(?:hostunknown|blocked|userunknown)/, 'b' => qr/\d\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

