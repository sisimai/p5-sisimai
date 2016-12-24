use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Order;

my $PackageName = 'Sisimai::Order';
my $MethodNames = {
    'class' => ['by', 'default', 'another', 'headers'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $default = Sisimai::Order->default;
    my $another = Sisimai::Order->another;
    my $headers = Sisimai::Order->headers;
    my $orderby = Sisimai::Order->by('subject');

    isa_ok $default, 'ARRAY';
    isa_ok $another, 'ARRAY';
    isa_ok $headers, 'HASH';
    isa_ok $orderby, 'HASH';
}

done_testing;

