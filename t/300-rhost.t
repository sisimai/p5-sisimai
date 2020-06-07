use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use Sisimai::Rhost;
use Sisimai::Reason;

my $PackageName = 'Sisimai::Rhost';
my $MethodNames = {
    'class' => ['match', 'get'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->match, undef;
    is $PackageName->get, undef;

    my $host = [
        'aspmx.l.google.com',
        'gmail-smtp-in.l.google.com',
        'neko.protection.outlook.com',
        'smtp.secureserver.net',
        'mailstore1.secureserver.net',
        'smtpz4.laposte.net',
        'smtp-in.orange.fr',
        'mx2.qq.com',
        'mx3.email.ua',
    ];

    for my $e ( @$host ) {
        ok $PackageName->match($e), '->match('.$e.')';
    }

    my $rset = Sisimai::Reason->index;
    for my $e ( glob('./set-of-emails/maildir/bsd/rhost-*.eml') ) {
        ok -f $e, $e;
        my $v = Sisimai->make($e);
        ok length $v->[0]->{'reason'}, 'reason = '.$v->[0]->{'reason'};
        ok length $v->[0]->{'rhost'},  'rhost = '.$v->[0]->{'rhost'};
    }
}

done_testing;

