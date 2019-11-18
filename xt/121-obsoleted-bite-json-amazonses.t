use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './xt/120-obsoleted-bite-json-code';

my $enginename = 'AmazonSES';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/  },
  # { 'n' => '02', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/  },
    { 'n' => '03', 's' => qr/\A\z/,          'r' => qr/feedback/,    'b' => qr/\A-1\z/ },
    { 'n' => '04', 's' => qr/\A2[.]6[.]0\z/, 'r' => qr/delivered/,   'b' => qr/\A-1\z/ },
    { 'n' => '05', 's' => qr/\A2[.]6[.]0\z/, 'r' => qr/delivered/,   'b' => qr/\A-1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

