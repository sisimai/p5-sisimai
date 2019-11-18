use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './xt/120-obsoleted-bite-json-code';

my $enginename = 'AmazonSES';
my $samplepath = sprintf("./set-of-emails/private/json-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [];

plan 'skip_all', sprintf("No private sample");
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

