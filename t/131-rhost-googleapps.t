use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Rhost;

my $PackageName = 'Sisimai::Rhost::GoogleApps';
my $MethodNames = {
    'class' => [ 'get' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->get, undef;

    use Sisimai::Mail;
    use Sisimai::Message;

    my $c = 0;

    PARSE_EACH_MAIL: for my $n ( 1..20 ) {

        my $emailfn = sprintf( "./eg/maildir-as-a-sample/new/google-apps-%02d.eml", $n );
        my $mailbox = Sisimai::Mail->new( $emailfn );
        my $mtahost = 'aspmx.l.google.com';
        next unless defined $mailbox;

        while( my $r = $mailbox->read ) {

            my $p = Sisimai::Message->new( 'data' => $r );
            isa_ok $p, 'Sisimai::Message';
            isa_ok $p->ds, 'ARRAY';
            isa_ok $p->header, 'HASH';
            isa_ok $p->rfc822, 'HASH';
            ok length $p->from;

            for my $e ( @{ $p->ds } ) {
                is $e->{'spec'}, 'SMTP', '->spec = SMTP';
                ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
                like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
                like $e->{'command'}, qr/[A-Z]{4}/, '->command = '.$e->{'command'};
                ok length $e->{'date'}, '->date = '.$e->{'date'};
                ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
                ok length $e->{'action'}, '->action = '.$e->{'action'};
                is $e->{'rhost'}, $mtahost, '->rhost = '.$mtahost;
                ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
                ok defined $e->{'alias'}, '->alias = '.$e->{'alias'};
                is $e->{'agent'}, 'Sendmail', '->agent = '.$e->{'agent'};
            }
            $c++;
        }
    }
    ok $c, 'the number of emails = '.$c;
}

done_testing;

