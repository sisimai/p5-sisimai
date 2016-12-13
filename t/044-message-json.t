use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;
use Sisimai::Message::JSON;

my $PackageName = 'Sisimai::Message::JSON';
my $MethodNames = {
    'class' => ['new', 'make', 'load', 'parse', 'makeorder'],
    'object' => ['from', 'header', 'ds', 'rfc822'],
};
my $SampleEmail = './set-of-emails/jsonapi/ced-us-amazonses-01.json';

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    use JSON;
    use IO::File;

    my $filehandle = IO::File->new($SampleEmail, 'r');
    my $jsonparser = JSON->new;
    my $jsonstring = <$filehandle>;
    my $tobeloaded = $PackageName->load;
    my $callbackto = sub {
        my $argvs = shift;
        my $catch = { 
            'feedback-id' => '',
            'account-id'  => '',
            'source-arn'  => '',
        };
        $catch->{'feedbackid'} = $argvs->{'message'}->{'bounce'}->{'feedbackId'} || '';
        $catch->{'account-id'} = $argvs->{'message'}->{'mail'}->{'sendingAccountId'} || '';
        $catch->{'source-arn'} = $argvs->{'message'}->{'mail'}->{'sourceArn'} || '';
        return $catch;
    };

    $filehandle->close;
    ok length $jsonstring;
    isa_ok $tobeloaded, 'ARRAY';

    my $j = $jsonparser->decode($jsonstring);
    my $p = Sisimai::Message->new('data' => $j, 'input' => 'json');

    isa_ok $p, 'Sisimai::Message';
    isa_ok $p->header, 'HASH', '->header';
    isa_ok $p->ds, 'ARRAY', '->ds';
    isa_ok $p->rfc822, 'HASH', '->rfc822';

    $p = Sisimai::Message->new(
            'data' => $j, 
            'hook' => $callbackto,
            'load' => ['Sisimai::Neko::Nyaan'],
            'input' => 'json',
            'order' => ['Sisimai::CED::US::AmazonSES'],
         );

    for my $e ( @{ $p->ds } ) {
        is $e->{'spec'}, 'SMTP', '->spec = SMTP';
        ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
        like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
        ok length $e->{'date'}, '->date = '.$e->{'date'};
        ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
        ok length $e->{'action'}, '->action = '.$e->{'action'};
        ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};
        ok exists $e->{'command'}, '->command = '.$e->{'command'};
        ok exists $e->{'rhost'}, '->rhost = '.$e->{'rhost'};

        for my $q ( 'rhost', 'lhost' ) {
            next unless $e->{ $q };
            like $e->{ $q }, qr/\A.+[.].+\z/, '->'.$q.' = '.$e->{ $q };
        }
        is $e->{'agent'}, 'CED::US::AmazonSES', '->agent = '.$e->{'agent'};
    }

    for my $e ( qw|to subject from message-id| ) {
        my $h = $p->rfc822->{ $e };
        ok length $h, $e;
    }

    ok keys(%{ $p->header }) == 0;
    isa_ok $p->catch, 'HASH';
    ok length $p->catch->{'feedbackid'};
    ok length $p->catch->{'account-id'};
    ok length $p->catch->{'source-arn'};
}

done_testing;

