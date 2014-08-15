use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::ISO3166;

my $PackageName = 'Sisimai::ISO3166';
my $MethodNames = {
    'class' => [ 'get' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->get, undef;
    is $PackageName->get('jp'), 'JP';
    is $PackageName->get('Gb','shortname'), 'United Kingdom';
    is $PackageName->get('US','alpha-2'), 'US';
    is $PackageName->get('dE','alpha-3'), 'DEU';
    is $PackageName->get('is','numeric'), 352;
    is $PackageName->get('vn','alpha-1'), '';
    is $PackageName->get('eg',undef), 'EG';
    is $PackageName->get('IR',[]), '';
    is $PackageName->get('AU',{}), '';
    is $PackageName->get('Br',), 'BR';
    is $PackageName->get('Cat',), '';
}

done_testing;


