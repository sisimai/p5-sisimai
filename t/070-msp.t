use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MSP;

my $PackageName = 'Sisimai::MSP';
my $MethodNames = {
    'class' => [ 
        'version', 'description', 'headerlist', 'scan',
        'SMTPCOMMAND', 'DELIVERYSTATUS', 'RFC822HEADERS', 'EOM',
    ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    ok $PackageName->version;
    ok $PackageName->smtpagent;
    is $PackageName->description, '', '->description';
    is $PackageName->scan, '', '->scan';

    isa_ok $PackageName->headerlist, 'ARRAY';
    isa_ok $PackageName->SMTPCOMMAND, 'HASH';
    isa_ok $PackageName->DELIVERYSTATUS, 'HASH';
    isa_ok $PackageName->RFC822HEADERS, 'ARRAY';
    isa_ok $PackageName->RFC822HEADERS('date'), 'ARRAY';
    isa_ok $PackageName->RFC822HEADERS('neko'), 'HASH';
    is $PackageName->EOM, '__END_OF_EMAIL_MESSAGE__';
}
done_testing;
