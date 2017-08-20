use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;

my $PackageName = 'Sisimai::Message';
my $MethodNames = {
    'class' => ['new', 'make', 'load'],
    'object' => ['from', 'header', 'ds', 'rfc822', 'catch'],
};
my $SampleFiles = {
    'mail' => './set-of-emails/mailbox/mbox-0',
    'json' => './set-of-emails/jsonobj/json-amazonses-01.json',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    isa_ok $PackageName->make, 'HASH';
    isa_ok $PackageName->load, 'ARRAY';

    use IO::File;
    EMAIL: {
        my $filehandle = IO::File->new($SampleFiles->{'mail'}, 'r');
        my $mailastext = '';

        while( my $r = <$filehandle> ) {
            $mailastext .= $r;
        }
        $filehandle->close;
        ok length $mailastext;

        my $p = $PackageName->new('data' => $mailastext);

        isa_ok $p, $PackageName;
        isa_ok $p->header, 'HASH', '->header';
        isa_ok $p->ds, 'ARRAY', '->ds';
        isa_ok $p->rfc822, 'HASH', '->rfc822';
        is $p->catch, undef;
        ok length $p->from, $p->from;
    }

    JSON: {
        use JSON;
        my $filehandle = IO::File->new($SampleFiles->{'json'}, 'r');
        my $jsonstring = <$filehandle>;
        my $jsonparser = JSON->new;

        $filehandle->close;
        ok length $jsonstring;

        my $j = $jsonparser->decode($jsonstring);
        my $p = $PackageName->new('data' => $j, 'input' => 'json');
        isa_ok $p, $PackageName;
        isa_ok $p->header, 'HASH', '->header';
        isa_ok $p->ds, 'ARRAY', '->ds';
        isa_ok $p->rfc822, 'HASH', '->rfc822';
        is $p->catch, undef;
    }

    UNSUPPORTED: {
        my $p = $PackageName->new('data' => 'neko', 'input' => 'neko');
        is $p, undef;
    }
}

done_testing;
