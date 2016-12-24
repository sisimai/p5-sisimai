use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use Sisimai::Reason;
require './t/999-values.pl';

my $PackageName = 'Sisimai::Reason';
my $MethodNames = {
    'class' => ['get', 'retry', 'index', 'match'],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->get, undef;
    is $PackageName->anotherone, undef;
    isa_ok $PackageName->index, 'ARRAY';
    isa_ok $PackageName->retry, 'ARRAY';

    use Sisimai::Mail;
    use Sisimai::Message;
    use Sisimai::Data;
    my $mailbox = Sisimai::Mail->new('set-of-emails/maildir/bsd/mta-sendmail-01.eml');

    while( my $r = $mailbox->read ) {
        my $o = Sisimai::Message->new('data' => $r);
        my $v = Sisimai::Data->make('data' => $o);
        isa_ok $v, 'ARRAY';

        for my $e ( @$v ) {
            isa_ok $e, 'Sisimai::Data';
            is $e->reason, 'userunknown';
        }
    }

    MATCH: {
        my $tablemodel;
        my $reasonlist = Sisimai->reason;

        for my $e ( @$Sisimai::Test::Values::ErrorText ) {
            my $v = Sisimai::Reason->match($e);
            my $r = Sisimai->match($e);

            ok $e, 'Diagnostic-Code: '.$e;
            ok $v, 'Detected reason: '.$v;
            ok grep { $v eq lc $_ } ( keys %$reasonlist );
            ok grep { $r eq lc $_ } ( keys %$reasonlist );
            ok $v, $r;
        }
    }
}

done_testing;

