use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::NotAccept;

my $PackageName = 'Sisimai::Reason::NotAccept';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'notaccept', '->text = notaccept';
    ok $PackageName->match('550 5.0.0 Domain does not exist: neko.example.jp');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;


