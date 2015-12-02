use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MSP;

my $PackageName = 'Sisimai::MSP';
my $MethodNames = {
    'class' => [ 
        'description', 'headerlist', 'scan', 'smtpagent', 'index', 'pattern',
        'DELIVERYSTATUS', 'LONGFIELDS', 'INDICATORS', 'RFC822HEADERS'
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    ok $PackageName->smtpagent;
    is $PackageName->description, '', '->description';
    is $PackageName->scan, '', '->scan';

    isa_ok $PackageName->index, 'ARRAY';
    isa_ok $PackageName->headerlist, 'ARRAY';
    isa_ok $PackageName->pattern, 'HASH';
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
    isa_ok $PackageName->LONGFIELDS, 'ARRAY';
    isa_ok $PackageName->INDICATORS, 'HASH';
    isa_ok $PackageName->RFC822HEADERS, 'ARRAY';
    isa_ok $PackageName->RFC822HEADERS('date'), 'ARRAY';
    isa_ok $PackageName->RFC822HEADERS('neko'), 'HASH';
}
done_testing;
