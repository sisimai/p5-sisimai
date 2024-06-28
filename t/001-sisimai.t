use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use IO::File;
use Sisimai;
use Time::Piece;
use JSON;
require './t/999-values.pl';

my $Package = 'Sisimai';
my $Methods = {
    'class'  => ['libname', 'version', 'rise', 'dump', 'engine', 'reason', 'match'],
    'object' => [],
};
my $Samples = {
    'mailbox' => './set-of-emails/mailbox/mbox-0',
    'maildir' => './set-of-emails/maildir/bsd',
    'memory'  => './set-of-emails/mailbox/mbox-1',
};
my $Normals = {
    'maildir' => './set-of-emails/maildir/not',
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $v  = $Sisimai::VERSION;
       $v .= 'p'.$Sisimai::PATCHLV if $Sisimai::PATCHLV > 0;
    is $Package->libname, $Package, '->libname = '.$Package;
    is 'v'.$Package->version, $v, '->version = v'.$v;
    is $Package->rise(undef), undef;
    is $Package->dump(undef), undef;

    # Wrong number of arguments
    eval { $Package->rise('/dev/null', undef) };
    like $@, qr/error: wrong number of arguments/;

    eval { $Package->dump('/dev/null', undef) };
    like $@, qr/error: wrong number of arguments/;

    for my $e ( keys %$Samples ) {
        MAKE: {
            my $parseddata = undef;
            my $damnedhash = undef;
            my $jsonstring = undef;

            if( $e eq 'memory' ) {
                my $filehandle = IO::File->new($Samples->{ $e }, 'r');
                my $entiremail = undef;

                { local $/ = undef; $entiremail = <$filehandle>; }
                ok ref $filehandle;
                ok length $entiremail;
                $filehandle->close;

                $parseddata = $Package->rise(\$entiremail);

            } else {
                $parseddata = $Package->rise($Samples->{ $e });
            }

            isa_ok $parseddata, 'ARRAY';
            ok scalar @$parseddata, 'entries = '.scalar @$parseddata;

            for my $ee ( @$parseddata ) {
                isa_ok $ee, 'Sisimai::Fact';
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

                for my $p ( @{ $argvs->{'fact'} } ) {
                    $p->{'parsedat'} = sprintf("%s %s", $timep->ymd('-'), $timep->hms);
                    $p->{'size'} = length $argvs->{'path'};
                    $p->{'kind'} = ucfirst $argvs->{'kind'};
                }
            };
            my $callbackto = sub {
                my $argvs = shift;
                my $catch = {
                    'x-mailer'        => '?',
                    'return-path'     => '?',
                    'x-virus-scanned' => '?',
                };

                $catch->{'from'} = $argvs->{'headers'}->{'from'} || 'Postmaster';
                $catch->{'x-virus-scanned'} = $argvs->{'headers'}->{'x-virus-scanned'} || '?';
                $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
                $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
                return $catch;
            };
            $havecaught = $Package->rise($Samples->{ $e }, 'c___' => [$callbackto, $emailhooks]);

            for my $ee ( @$havecaught ) {
                isa_ok $ee, 'Sisimai::Fact';
                isa_ok $ee->catch, 'HASH';

                like $ee->catch->{'x-mailer'}, qr/[A-Z?]/;
                like $ee->catch->{'return-path'}, qr/(?:<>|.+[@].+|mailer-daemon|[?])/i;
                like $ee->catch->{'from'}, qr/(?:<>|.+[@].+|mailer-daemon|postmaster|[?])/i;
                like $ee->catch->{'x-virus-scanned'}, qr/(?:amavis|clam|[?])/i;
                like $ee->{'parsedat'}, qr/\A\d{4}[-]\d{2}[-]\d{2}/;
                ok   $ee->{'size'} > 0;
                like $ee->{'kind'}, qr/\AMail(?:box|dir)/;
            }

            my $isntmethod = $Package->rise($Samples->{ $e }, 'c___' => []);
            for my $ee ( @$isntmethod ) {
                isa_ok $ee, 'Sisimai::Fact';
                is $ee->catch, undef;
            }
        }

        DUMP: {
            my $jsonstring = $Package->dump($Samples->{ $e });
            my $perlobject = undef;
            my $tobetested = [qw|addresser recipient senderdomain destination reason timestamp token smtpagent origin|];
            ok length $jsonstring;
            utf8::encode $jsonstring if utf8::is_utf8 $jsonstring;
            $perlobject = JSON::decode_json($jsonstring);

            isa_ok $perlobject, 'ARRAY';
            for my $ee ( @$perlobject ) {
                isa_ok $ee, 'HASH';
                is ref $ee->{'addresser'}, '', '->{addresser} is a String';
                is ref $ee->{'recipient'}, '', '->{reciipent} is a String';

                for my $eee ( @$tobetested ) {
                    next if $eee eq 'senderdomain';
                    ok $ee->{ $eee }, $eee.' = '.$ee->{ $eee };
                }
            }
        }
    }

    for my $e ( 'maildir' ) {
        my $parseddata = $Package->rise($Normals->{ $e });
        my $jsonstring = $Package->dump($Normals->{ $e });
        is $parseddata, undef, '->rise = undef';
        is $jsonstring, '[]', '->dump = "[]"';
    }

    ENGINE: {
        my $enginelist = $Package->engine;
        isa_ok $enginelist, 'HASH';
        ok scalar(keys %$enginelist), '->engine = '.scalar(keys %$enginelist);
        for my $e ( keys %$enginelist ) {
            like $e, qr/\ASisimai::/, '->engine = '.$e;
            ok length $enginelist->{ $e }, '->engine->{'.$e.'} = '.$enginelist->{ $e };
        }
    }

    REASON: {
        my $reasonlist = $Package->reason;
        isa_ok $reasonlist, 'HASH';
        ok scalar(keys %$reasonlist), '->reason = '.scalar(keys %$reasonlist);
        for my $e ( keys %$reasonlist ) {
            like $e, qr/\A[A-Z]/, '->reason = '.$e;
            ok length $reasonlist->{ $e }, '->reason->{'.$e.'} = '.$reasonlist->{ $e };
        }
    }

    MATCH: {
        is(Sisimai->match('550 5.1.1 User unknown'), 'userunknown');
        is(Sisimai->match(''), undef);
    }
}
done_testing;

