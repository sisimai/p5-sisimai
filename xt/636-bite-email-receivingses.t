use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'ReceivingSES';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [];

plan 'skip_all', sprintf("no private sample");
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

