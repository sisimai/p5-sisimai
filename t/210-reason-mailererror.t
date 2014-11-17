use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::MailerError;

my $PackageName = 'Sisimai::Reason::MailerError';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'mailererror', '->text = mailererror';
    ok $PackageName->match('X-Unix; 255');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



