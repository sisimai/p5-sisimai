use strict;
no warnings 'once';
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Time;

my $Package = 'Sisimai::Time';
my $Methods = {
    'class'  => [],
    'object' => ['TO_JSON'],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'object'} };

MAKETEST: {
    my $v = $Package->new;
    my $t = Time::Piece->new;

    isa_ok $v, $Package;
    is $v->TO_JSON, $v->epoch, 'TO_JSON() = '.$v->epoch;
}

done_testing();
