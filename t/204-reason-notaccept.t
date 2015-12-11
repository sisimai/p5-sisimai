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
    ok $PackageName->match('SMTP protocol returned a permanent error');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;


