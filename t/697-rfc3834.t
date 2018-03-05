use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'RFC3834';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [];

$enginetest->($enginename, $isexpected);
done_testing;

