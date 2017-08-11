use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/700-bite-json-code';

my $enginename = 'AmazonSES';
my $samplepath = sprintf("./set-of-emails/private/json-%s", lc $enginename);
my $enginetest = Sisimai::Bite::JSON::Code->maketest;
my $isexpected = [];

plan 'skip_all', sprintf("No private sample");
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

