use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Bite::Email;

my $PackageName = 'Sisimai::Bite::Email';
my $MethodNames = {
    'class' => [
        'description', 'headerlist', 'scan', 'smtpagent', 'index', 'pattern',
        'DELIVERYSTATUS', 'INDICATORS',
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    ok $PackageName->smtpagent;
    is $PackageName->description, '', '->description';
    is $PackageName->scan, undef, '->scan';

    isa_ok $PackageName->index, 'ARRAY';
    isa_ok $PackageName->headerlist, 'ARRAY';
    isa_ok $PackageName->pattern, 'HASH';
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
    isa_ok $PackageName->INDICATORS, 'HASH';
}
done_testing;
