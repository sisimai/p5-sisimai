use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use IO::File;
use Sisimai;
use JSON;
require './t/999-values.pl';

my $PackageName = 'Sisimai';
my $MethodNames = {
    'class' => [
        'sysname', 'libname', 'version', 'make', 'dump', 'engine', 'match',
    ],
    'object' => [],
};
my $SampleJSONs = [
    'json-amazonses-01.json',
#   'json-amazonses-02.json',
    'json-amazonses-03.json',
#   'json-amazonses-04.json',
#   'json-amazonses-05.json',
    'json-amazonses-06.json',
    'son-sendgrid-01.json',
    'json-sendgrid-02.json',
    'json-sendgrid-03.json',
    'json-sendgrid-04.json',
    'json-sendgrid-05.json',
    'json-sendgrid-06.json',
    'json-sendgrid-07.json',
    'json-sendgrid-08.json',
    'json-sendgrid-09.json',
    'json-sendgrid-10.json',
    'json-sendgrid-11.json',
    'json-sendgrid-12.json',
#   'json-sendgrid-13.json',
    'json-sendgrid-14.json',
    'json-sendgrid-15.json',
    'json-sendgrid-16.json',
    'json-sendgrid-17.json',
];

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    for my $e ( @$SampleJSONs ) {
        my $p = 'set-of-emails/obsoleted/'.$e;
        next unless -f $p;

        MAKE: {
            my $parseddata = undef;
            my $damnedhash = undef;
            my $jsonstring = undef;
            my $filehandle = IO::File->new($p, 'r');
            my $jsonparser = JSON->new;
            my $jsonobject = $jsonparser->decode(<$filehandle>);

            ok ref $filehandle;
            ok ref $jsonparser;
            ok ref $jsonobject;
            $filehandle->close;

            $parseddata = $PackageName->make($jsonobject, 'input' => 'json');
            isa_ok $parseddata, 'ARRAY';
            ok scalar @$parseddata, 'entries = '.scalar @$parseddata;

            for my $ee ( @$parseddata ) {
                isa_ok $ee, 'Sisimai::Data';
                isa_ok $ee->timestamp, 'Sisimai::Time';
                isa_ok $ee->addresser, 'Sisimai::Address';
                isa_ok $ee->recipient, 'Sisimai::Address';
                ok $ee->addresser->address, '->addresser = '.$ee->addresser->address;
                ok $ee->recipient->address, '->recipient = '.$ee->recipient->address;
                ok length  $ee->reason, '->reason = '.$ee->reason;
                ok defined $ee->replycode, '->replycode = '.$ee->replycode;

                $damnedhash = $ee->damn;
                isa_ok $damnedhash, 'HASH';
                ok scalar keys %$damnedhash;
                is $damnedhash->{'recipient'}, $ee->recipient->address, '->recipient = '.$damnedhash->{'recipient'};
                is $damnedhash->{'addresser'}, $ee->addresser->address, '->addresser = '.$damnedhash->{'addresser'};

                for my $eee ( keys %$damnedhash ) {
                    next if ref $ee->$eee;
                    next if $eee eq 'subject';
                    if( $eee eq 'catch' ) {
                        is $damnedhash->{ $eee }, '', '->'.$eee.' = ""';
                    } else {
                        is $damnedhash->{ $eee }, $ee->$eee, '->'.$eee.' = '.$damnedhash->{ $eee };
                    }
                }

                $jsonstring = $ee->dump('json');
                ok length $jsonstring, 'length(dump("json")) = '.length $jsonstring;
            }

            my $havecaught = undef;
            my $callbackto = sub {
                my $argvs = shift;
                my $catch = { 
                    'type' => $argvs->{'datasrc'},
                    'feedbackid' => '',
                    'account-id' => '',
                    'source-arn' => '',
                };

                if( $argvs->{'datasrc'} eq 'json' ) {
                    $catch->{'feedbackid'} = $argvs->{'bounces'}->{'bounce'}->{'feedbackId'} || '';
                    $catch->{'account-id'} = $argvs->{'bounces'}->{'mail'}->{'sendingAccountId'} || '';
                    $catch->{'source-arn'} = $argvs->{'bounces'}->{'mail'}->{'sourceArn'} || '';
                }
                return $catch;
            };

            my $filehandle = IO::File->new($p, 'r');
            my $jsonparser = JSON->new;
            my $jsonobject = $jsonparser->decode(<$filehandle>);

            $filehandle->close;
            $havecaught = $PackageName->make($jsonobject, 'hook' => $callbackto, 'input' => 'json');

            for my $ee ( @$havecaught ) {
                isa_ok $ee, 'Sisimai::Data';
                isa_ok $ee->catch, 'HASH';
                is $ee->catch->{'type'}, 'json';
                ok defined $ee->catch->{'feedbackid'};
                ok defined $ee->catch->{'account-id'};
                ok defined $ee->catch->{'source-arn'};
            }

            my $isntmethod = $PackageName->make($p, 'hook' => {});
            for my $ee ( @$isntmethod ) {
                isa_ok $ee, 'Sisimai::Data';
                is $ee->catch, undef;
            }
        }

        DUMP: {
            my $jsonstring = $PackageName->dump($p);
            my $perlobject = undef;
            my $tobetested = [ qw|
                addresser recipient senderdomain destination reason timestamp 
                token smtpagent|
            ];
            ok length $jsonstring;
            utf8::encode $jsonstring if utf8::is_utf8 $jsonstring;
            $perlobject = JSON::decode_json($jsonstring);

            isa_ok $perlobject, 'ARRAY';
            for my $ee ( @$perlobject ) {
                isa_ok $ee, 'HASH';
                is ref $ee->{'addresser'}, '', '->{addresser} is a String';
                is ref $ee->{'recipient'}, '', '->{reciipent} is a String';

                for my $eee ( @$tobetested ) {
                    if( $eee eq 'senderdomain' && $ee->{'addresser'} =~ /\A(?:postmaster|MAILER-DAEMON)\z/ ) {
                        # addresser = postmaster
                        is $ee->{'senderdomain'}, '', $eee.' = ""';

                    } else {
                        # other properties
                        ok $ee->{ $eee }, $eee.' = '.$ee->{ $eee };
                    }
                }
            }
        }
    }
}
done_testing;

