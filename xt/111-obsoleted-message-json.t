use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;

my $PackageName = 'Sisimai::Message';
my $MethodNames = {
    'class' => ['new', 'make', 'load', 'parse', 'makeorder'],
    'object' => ['from', 'header', 'ds', 'rfc822'],
};
my $SampleJSONs = './set-of-emails/obsoleted/json-sendgrid/json-sendgrid-03.json';

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    use JSON;
    use IO::File;
    last unless -f $SampleJSONs;

    my $filehandle = IO::File->new($SampleJSONs, 'r');
    my $jsonparser = JSON->new;
    my $jsonstring = <$filehandle>;
    my $tobeloaded = $PackageName->load;
    my $callbackto = sub {
        my $argvs = shift;
        my $catch = { 'email' => '', 'type' => 'json' };
        $catch->{'email'} = $argvs->{'bounces'}->{'email'} || '';
        return $catch;
    };

    $filehandle->close;
    ok length $jsonstring;
    isa_ok $tobeloaded, 'ARRAY';

    my $j = $jsonparser->decode($jsonstring);
    my $p = Sisimai::Message->new('data' => $j->[0], 'input' => 'json');

    isa_ok $p, 'Sisimai::Message';
    isa_ok $p->header, 'HASH', '->header';
    isa_ok $p->ds, 'ARRAY', '->ds';
    isa_ok $p->rfc822, 'HASH', '->rfc822';

    $p = Sisimai::Message->new(
            'data' => $j->[0], 
            'hook' => $callbackto,
            'load' => ['Sisimai::Neko::Nyaan'],
            'input' => 'json',
            'order' => ['Sisimai::Lhost::AmazonSES', 'Sisimai::Lhost::SendGrid'],
         );

    for my $e ( @{ $p->ds } ) {
        ok defined $e->{'spec'}, '->spec = '.$e->{'spec'};
        ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
        like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
        ok length $e->{'date'}, '->date = '.$e->{'date'};
        ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
        ok exists $e->{'action'}, '->action = '.$e->{'action'};
        ok exists $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
        ok exists $e->{'command'}, '->command = '.$e->{'command'};
        ok exists $e->{'rhost'}, '->rhost = '.$e->{'rhost'};
        is $e->{'agent'}, 'JSON::SendGrid', '->agent = '.$e->{'agent'};
    }

    ok keys(%{ $p->header }) == 0;
    isa_ok $p->catch, 'HASH';
    is $p->catch->{'type'}, 'json';
    ok length $p->catch->{'email'};
}

done_testing;

