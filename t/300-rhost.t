use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost';
my $MethodNames = {
    'class' => [ 'list', 'match', 'get' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->list, 'ARRAY';
    is $PackageName->match, undef;
    is $PackageName->get, undef;

    my $list = $PackageName->list;
    my $host = 'aspmx.l.google.com';

    ok $PackageName->match( $host );
    ok grep { $host eq $_ } @$list;

}

done_testing;

