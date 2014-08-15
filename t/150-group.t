use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Group;

my $PackageName = 'Sisimai::Group';
my $MethodNames = {
    'class' => [ 'find' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v = undef;
    is $PackageName->find, undef,
    $v = $PackageName->find( 'email' => 'root@localhost.localdomain' );
    isa_ok $v, 'HASH';
    is $v->{'category'}, 'pc';
    is $v->{'provider'}, 'local';

    $v = $PackageName->find( 'email' => 'root@example.com' );
    isa_ok $v, 'HASH';
    is $v->{'category'}, 'reserved';
    is $v->{'provider'}, 'ietf';
}

done_testing;


