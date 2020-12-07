use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use Sisimai::Reason;
require './t/999-values.pl';

my $Package = 'Sisimai::Reason';
my $Methods = {
    'class' => ['get', 'path', 'retry', 'index', 'match'],
    'object' => [],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is $Package->get, undef;
    is $Package->anotherone, undef;
    isa_ok $Package->index, 'ARRAY';
    isa_ok $Package->retry, 'HASH';
    isa_ok $Package->path,  'HASH';

    use Sisimai::Mail;
    use Sisimai::Fact;
    my $mailbox = Sisimai::Mail->new('set-of-emails/maildir/bsd/lhost-sendmail-01.eml');

    while( my $r = $mailbox->data->read ) {
        my $v = Sisimai::Fact->rise({'data' => $r});
        isa_ok $v, 'ARRAY';

        for my $e ( @$v ) {
            isa_ok $e, 'Sisimai::Fact';
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

