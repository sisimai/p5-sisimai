use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Bite::JSON;

my $PackageName = 'Sisimai::Bite::JSON';
my $MethodNames = {
    'class' => ['index', 'scan', 'adapt', 'smtpagent', 'description', 'DELIVERYSTATUS'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    ok $PackageName->smtpagent;
    is $PackageName->description, '', '->description';
    is $PackageName->scan, undef, '->scan';
    is $PackageName->adapt, undef, '->adapt';

    isa_ok $PackageName->index, 'ARRAY';
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
}
done_testing;

