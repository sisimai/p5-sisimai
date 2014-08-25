use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
require 't/900-modules.pl';

for my $e ( @{ Sisimai::Test::Modules->list() } ) {
    my $v = $e; $v =~ s|/|::|g; $v =~ s/[.]pm//g;
    use_ok $v;
}
done_testing;
