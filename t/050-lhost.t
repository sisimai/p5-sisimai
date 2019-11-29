use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Lhost;

my $PackageName = 'Sisimai::Lhost';
my $MethodNames = {
    'class' => [
        'description', 'headerlist', 'make', 'smtpagent', 'index', 'heads',
        'DELIVERYSTATUS', 'INDICATORS',
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    ok $PackageName->smtpagent;
    is $PackageName->description, '', '->description';
    is $PackageName->make, undef, '->make';

    isa_ok $PackageName->index, 'ARRAY';
    isa_ok $PackageName->heads, 'ARRAY';
    isa_ok $PackageName->headerlist, 'ARRAY';
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
    isa_ok $PackageName->INDICATORS, 'HASH';
}
done_testing;
