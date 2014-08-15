use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;

my $PackageName = 'Sisimai::Message';
my $MethodNames = {
    'class' => [ 'new', 'resolve', 'rewrite' ],
    'object' => [ 'from', 'header', 'ds', 'rfc822' ],
};
my $SampleEmail = './eg/mbox-as-a-sample';

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    use IO::File;
    my $filehandle = IO::File->new( $SampleEmail, 'r' );
    my $mailastext = '';

    while( my $r = <$filehandle> ) {
        $mailastext .= $r;
    }
    $filehandle->close;
    ok length $mailastext;

    my $p = $PackageName->new( 'data' => $mailastext );

    isa_ok $p, $PackageName;
    isa_ok $p->header, 'HASH', '->header';
    isa_ok $p->ds, 'ARRAY', '->ds';
    isa_ok $p->rfc822, 'HASH', '->rfc822';
    ok length $p->from, $p->from;

    for my $e ( @{ $p->ds } ) {
        is $e->{'spec'}, 'SMTP', '->spec = SMTP';
        ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
        like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
        like $e->{'command'}, qr/[A-Z]{4}/, '->command = '.$e->{'command'};
        ok length $e->{'date'}, '->date = '.$e->{'date'};
        ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
        ok length $e->{'action'}, '->action = '.$e->{'action'};
        ok length $e->{'rhost'}, '->rhost = '.$e->{'rhost'};
        ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
        is $e->{'agent'}, 'Sendmail', '->agent = '.$e->{'agent'};
    }

    for my $e ( 'content-type', 'to', 'subject', 'date', 'from', 'message-id' ) {
        my $h = $p->header->{ $e };
        ok length $h, $h;
    }
    isa_ok $p->header->{'received'}, 'ARRAY';

    for my $e ( 'return-path', 'delivered-to', 'to', 'subject', 'date', 'from', 'message-id', 'reply-to' ) {
        my $h = $p->rfc822->{ $e };
        ok length $h, $e;
    }
}

done_testing;
