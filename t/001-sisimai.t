use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use IO::File;
use Sisimai;
use Time::Piece;
use JSON;
require './t/999-values.pl';

my $PackageName = 'Sisimai';
my $MethodNames = {
    'class' => [
        'sysname', 'libname', 'version', 'make', 'dump', 'engine', 'match',
    ],
    'object' => [],
};
my $SampleEmail = {
    'mailbox' => './set-of-emails/mailbox/mbox-0',
    'maildir' => './set-of-emails/maildir/bsd',
    'memory'  => './set-of-emails/mailbox/mbox-1',
};
my $IsNotBounce = {
    'maildir' => './set-of-emails/maildir/not',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v  = $Sisimai::VERSION;
       $v .= 'p'.$Sisimai::PATCHLV if $Sisimai::PATCHLV > 0;
    is $PackageName->sysname, 'bouncehammer', '->sysname = bouncehammer';
    is $PackageName->libname, $PackageName, '->libname = '.$PackageName;
    is 'v'.$PackageName->version, $v, '->version = v'.$v;
    is $PackageName->make(undef), undef;
    is $PackageName->dump(undef), undef;

    # Wrong number of arguments
    eval { $PackageName->make('/dev/null', undef) };
    like $@, qr/error: wrong number of arguments/;

    eval { $PackageName->dump('/dev/null', undef) };
    like $@, qr/error: wrong number of arguments/;

    for my $e ( 'mailbox', 'maildir', 'memory' ) {
        MAKE: {
            my $parseddata = undef;
            my $damnedhash = undef;
            my $jsonstring = undef;

            if( $e eq 'memory' ) {
                my $filehandle = IO::File->new($SampleEmail->{ $e }, 'r');
                my $entiremail = undef;

                { local $/ = undef; $entiremail = <$filehandle>; }
                ok ref $filehandle;
                ok length $entiremail;
                $filehandle->close;

                $parseddata = $PackageName->make(\$entiremail);

            } else {
                $parseddata = $PackageName->make($SampleEmail->{ $e });
            }

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
            my $emailhooks = sub {
                my $argvs = shift;
                my $timep = localtime(Time::Piece->new);

                for my $p ( @{ $argvs->{'sisi'} } ) {
                    $p->{'parsedat'} = sprintf("%s %s", $timep->ymd('-'), $timep->hms);
                    $p->{'size'} = length $argvs->{'path'};
                    $p->{'kind'} = ucfirst $argvs->{'kind'};
                }
            };
            my $callbackto = sub {
                my $argvs = shift;
                my $catch = { 
                    'x-mailer' => '',
                    'return-path' => '',
                    'x-virus-scanned' => '',
                };

                $catch->{'from'} = $argvs->{'headers'}->{'from'} || '';
                $catch->{'x-virus-scanned'} = $argvs->{'headers'}->{'x-virus-scanned'} || '';
                $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
                $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
                return $catch;
            };
            $havecaught = $PackageName->make($SampleEmail->{ $e }, 'hook' => $callbackto, 'c___' => $emailhooks);

            for my $ee ( @$havecaught ) {
                isa_ok $ee, 'Sisimai::Data';
                isa_ok $ee->catch, 'HASH';

                ok defined $ee->catch->{'x-mailer'};
                if( length $ee->catch->{'x-mailer'} ) {
                    like $ee->catch->{'x-mailer'}, qr/[A-Z]/;
                }

                ok defined $ee->catch->{'return-path'};
                if( length $ee->catch->{'return-path'} ) {
                    like $ee->catch->{'return-path'}, qr/(?:<>|.+[@].+|<mailer-daemon>)/i;
                }

                ok defined $ee->catch->{'from'};
                if( length $ee->catch->{'from'} ) {
                    like $ee->catch->{'from'}, qr/(?:<>|.+[@].+|<?mailer-daemon>?)/i;
                }

                ok defined $ee->catch->{'x-virus-scanned'};
                if( length $ee->catch->{'x-virus-scanned'} ) {
                    like $ee->catch->{'x-virus-scanned'}, qr/(?:amavis|clam)/i;
                }

                ok $ee->{'parsedat'};
                like $ee->{'parsedat'}, qr/\A\d{4}[-]\d{2}[-]\d{2}/;

                ok $ee->{'size'};
                ok $ee->{'size'} > 0;

                ok $ee->{'kind'};
                like $ee->{'kind'}, qr/\AMail(?:box|dir)/;
            }

            my $isntmethod = $PackageName->make($SampleEmail->{ $e }, 'hook' => {});
            for my $ee ( @$isntmethod ) {
                isa_ok $ee, 'Sisimai::Data';
                is $ee->catch, undef;
            }
        }

        DUMP: {
            my $jsonstring = $PackageName->dump($SampleEmail->{ $e });
            my $perlobject = undef;
            my $tobetested = [ qw|
                addresser recipient senderdomain destination reason timestamp 
                token smtpagent origin|
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

    for my $e ( 'maildir' ) {
        my $parseddata = $PackageName->make($IsNotBounce->{ $e });
        my $jsonstring = $PackageName->dump($IsNotBounce->{ $e });
        is $parseddata, undef, '->make = undef';
        is $jsonstring, '[]', '->dump = "[]"';
    }

    ENGINE: {
        my $enginelist = $PackageName->engine;
        isa_ok $enginelist, 'HASH';
        ok scalar(keys %$enginelist), '->engine = '.scalar(keys %$enginelist);
        for my $e ( keys %$enginelist ) {
            like $e, qr/\ASisimai::/, '->engine = '.$e;
            ok length $enginelist->{ $e }, '->engine->{'.$e.'} = '.$enginelist->{ $e };
        }
    }

    REASON: {
        my $reasonlist = $PackageName->reason;
        isa_ok $reasonlist, 'HASH';
        ok scalar(keys %$reasonlist), '->reason = '.scalar(keys %$reasonlist);
        for my $e ( keys %$reasonlist ) {
            like $e, qr/\A[A-Z]/, '->reason = '.$e;
            ok length $reasonlist->{ $e }, '->reason->{'.$e.'} = '.$reasonlist->{ $e };
        }
    }
}
done_testing;

