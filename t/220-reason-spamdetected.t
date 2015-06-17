use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::SpamDetected;

my $PackageName = 'Sisimai::Reason::SpamDetected';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'spamdetected', '->text = spamdetected';
    ok $PackageName->match('570 5.7.7 Spam Detected');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;

