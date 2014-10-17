use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::SystemFull;

my $PackageName = 'Sisimai::Reason::SystemFull';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'systemfull', '->text = systemfull';
    ok $PackageName->match('550 5.0.0 Mail system full');
    is $PackageName->match('400 4.0.0 Mailbox full'), 0;
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



