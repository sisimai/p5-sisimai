use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP;

my $PackageName = 'Sisimai::SMTP';
my $MethodNames = {
    'class' => [ 'command', 'is_softbounce' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->command, 'HASH';
    is $PackageName->is_softbounce('450 4.7.1 Client host rejected'), 1;
    is $PackageName->is_softbounce('553 5.3.5 system config error'), 0;
    is $PackageName->is_softbounce('250 OK'), -1;
}

done_testing;
