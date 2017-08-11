use Test::More;
use Module::Load;

eval { Module::Load::load 'Test::UsedModules'; };
plan 'skip_all' => 'No Test::UsedModules' if $@;

require './t/900-modules.pl';

for my $e ( @{ Sisimai::Test::Modules->list() } ) { 
    my $v = 'lib/'.$e;
    next if $e eq 'Sisimai/Bite/Email.pm';
    ok -f $v, $v;
    Test::UsedModules::used_modules_ok($v);
}
done_testing;
