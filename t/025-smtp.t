use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP;

my $PackageName = 'Sisimai::SMTP';
my $MethodNames = {
    'class' => [],
    'object' => [],
};

use_ok $PackageName;
done_testing;
