use strict;
no warnings 'once';
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Time;

my $PackageName = 'Sisimai::Time';
my $MethodNames = {
    'class'  => [],
    'object' => ['TO_JSON'],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'object'} };

MAKE_TEST: {
    my $v = $PackageName->new;
    my $t = Time::Piece->new;

    isa_ok $v, $PackageName;
    is $v->TO_JSON, $v->epoch, 'TO_JSON() = '.$v->epoch;
}

done_testing();
