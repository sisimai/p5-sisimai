use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP;

my $PackageName = 'Sisimai::SMTP';
my $MethodNames = {
    'class' => ['command'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->command, 'HASH';
}

done_testing;
