use Test::More;
use Test::UsedModules;
require './t/900-modules.pl';

for my $e ( @{ Sisimai::Test::Modules->list() } ) { 
    my $v = 'lib/'.$e;
    ok -f $v, $v;
    used_modules_ok( $v );
}
done_testing;
