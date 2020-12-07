use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP;

my $Package = 'Sisimai::SMTP';
my $Methods = { 'class'  => [], 'object' => [] };

use_ok $Package;
done_testing;
