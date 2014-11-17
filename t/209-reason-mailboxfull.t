use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Reason::MailboxFull;

my $PackageName = 'Sisimai::Reason::MailboxFull';
my $MethodNames = {
    'class' => [ 'text', 'match', 'true' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->text, 'mailboxfull', '->text = mailboxfull';
    ok $PackageName->match('400 4.0.0 Mailbox full');
    is $PackageName->true, undef, '->true = undef';
}

done_testing;



