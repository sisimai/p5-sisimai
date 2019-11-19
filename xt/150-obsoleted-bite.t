use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Bite;

my $PackageName = 'Sisimai::Bite';
my $MethodNames = {
    'class' => ['DELIVERYSTATUS', 'smtpagent', 'description'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v = $PackageName->DELIVERYSTATUS;
    isa_ok $v, 'HASH';
    ok keys %$v;

    like $PackageName->smtpagent, qr/\ASisimai::Bite\z/;
    is $PackageName->description, '';
}

done_testing;
