use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use JSON;

my $Package = 'Sisimai::Fact';
my $Methods = { 'class' => ['rise'], 'object' => ['softbounce', 'dump', 'damn'] };
my $Results = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '00' => [
        ['5.1.2',   '550', 'hostunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.2.2',   '552', 'mailboxfull',     0],
        ['5.2.0',   '550', 'filtered',        0],
        ['5.3.4',   '552', 'mesgtoobig',      0],
        ['5.0.0',   '',    'suspend',         0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.3.4',   '552', 'mesgtoobig',      0],
        ['5.2.0',   '',    'filtered',        0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['4.2.2',   '',    'mailboxfull',     0],
        ['5.3.4',   '552', 'mesgtoobig',      0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.3.4',   '552', 'mesgtoobig',      0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.0',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.0.0',   '554', 'filtered',        0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.7.0',   '552', 'policyviolation', 0],
        ['5.2.3',   '552', 'exceedlimit',     0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.2.3',   '552', 'exceedlimit',     0],
        ['5.7.1',   '553', 'filtered',        0],
        ['5.1.1',   '550', 'userunknown',     1],
        ['5.1.1',   '',    'userunknown',     1],
        ['5.3.4',   '552', 'mesgtoobig',      0],
        ['4.2.2',   '450', 'mailboxfull',     0],
        ['5.7.1',   '550', 'norelaying',      0],
        ['5.0.0',   '',    'mailererror',     0],
        ['5.2.0',   '550', 'filtered',        0],
        ['5.1.1',   '550', 'userunknown',     1],
    ],
    '01' => [['5.1.1',   '550', 'userunknown',     1]],
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is $Package->rise, undef;
    is $Package->rise({'data' => ''}), undef;
    is $Package->rise({'data' => 'test', 'load' => ''}), undef;
    is $Package->rise({'data' => 'test', 'load' => [], 'order' => ''}), undef;

    my $json = JSON->new;
    my $call = sub {
        my $argvs = shift;
        my $catch = { 'from' => '', 'x-mailer' => 'N/A', 'return-path' => '<>' };
        $catch->{'from'}        = $argvs->{'headers'}->{'from'} || '';
        $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
        $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
        return $catch;
    };

    my $ci = 0;
    my $ct = '';

    for my $e ( glob('./set-of-emails/mailbox/mbox-*') ) {
        # Parse each UNIX mobx file
        my $cf = Sisimai->rise($e, 'c___' => [$call], 'delivered' => 1);
        my $ce = 1;
        my $cx = $Results->{sprintf("%02d", $ci)};
        my $cv = undef;
        my $cj = undef;

        isa_ok $cf, 'ARRAY';
        ok scalar @$cf, sprintf("[mobx-%02d]", $ci);

        while( my $e = shift @$cf ) {
            # Test each fact
            isa_ok $e, 'Sisimai::Fact';
            isa_ok $e->addresser, 'Sisimai::Address';
            isa_ok $e->recipient, 'Sisimai::Address';
            isa_ok $e->timestamp, 'Sisimai::Time';
            isa_ok $e->catch,     'HASH';

            $ct = sprintf("[%02d-%02d]", $ci, $ce);
            $cx = $Results->{ sprintf("%02d", $ci) }->[$ce - 1];

            is $e->deliverystatus, $cx->[0], sprintf("%s ->deliverystatus = %s", $ct, $cx->[0]);
            is $e->replycode,      $cx->[1], sprintf("%s ->replycode = %s",      $ct, $cx->[1]);
            is $e->reason,         $cx->[2], sprintf("%s ->reason = %s",         $ct, $cx->[2]);
            is $e->hardbounce,     $cx->[3], sprintf("%s ->hardbounce = %s",     $ct, $cx->[3]);
            is $e->softbounce,     $e->hardbounce ? 0 : 1;

            $cv = $e->catch;
            ok $cv->{'from'},        sprintf("%s ->catch(from) = %s", $ct, $cv->{'from'});
            ok $cv->{'x-mailer'},    sprintf("%s ->catch(x-mailer) = %s", $ct, $cv->{'x-mailer'});
            ok $cv->{'return-path'}, sprintf("%s ->catch(return-path) = %s", $ct, $cv->{'return-path'});


            # DAMN()
            $cv = $e->damn;
            isa_ok $cv, 'HASH';
            ok $cv->{'addresser'} =~ /\A.+[@]/, sprintf("%s ->addresser", $ct);
            ok $cv->{'recipient'} =~ /\A.+[@]/, sprintf("%s ->recipient", $ct);
            ok $cv->{'timestamp'} -~ /\A\d+\z/, sprintf("%s ->timestamp", $ct);;

            is $cv->{'addresser'}, $e->addresser->address, sprintf("%s ->addresser = %s", $ct, $cv->{'addresser'});
            is $cv->{'recipient'}, $e->recipient->address, sprintf("%s ->recipient = %s", $ct, $cv->{'recipient'});
            is $cv->{'timestamp'}, $e->timestamp->epoch,   sprintf("%s ->timestamp = %d", $ct, $cv->{'timestamp'});


            # JSON
            $cv = $e->dump('json');     ok length $cv, sprintf("%s ->dump(json) = %s", $ct, substr($cv, 0, 32));
            $cv = $e->dump();           ok length $cv, sprintf("%s ->dump() = %s",     $ct, substr($cv, 0, 32));
            $cj = $json->decode($cv);   isa_ok $cj, 'HASH';

            is $cj->{'action'}, $e->action, sprintf("%s ->action = %s", $ct, $e->action);
            is $cj->{'listid'}, $e->listid, sprintf("%s ->listid = %s", $ct, $e->listid);

            is $cj->{'timestamp'},    $e->timestamp->epoch, sprintf("%s ->timestamp = %d", $ct, $cj->{'timestamp'});
            is $cj->{'destination'},  $e->recipient->host,  sprintf("%s ->destination = %s", $ct, $cj->{'destination'});
            is $cj->{'senderdomain'}, $e->addresser->host,  sprintf("%s ->senderdomain = %s", $ct, $cj->{'senderdomain'});

            isa_ok $cj->{'catch'}, 'HASH';
            is $cj->{'catch'}->{'from'}, $e->catch->{'from'}, sprintf("%s ->catch->from = %s", $ct, $e->catch->{'from'});

            eval {
                # YAML; this module is an optional
                require YAML;
                $cv = $e->dump('yaml'); ok length $cv, sprintf("%s ->dump(yaml) = %s", $ct, substr($cv, 0, 3));
                $cj = YAML::Load($cv);  isa_ok $cj, 'HASH';
                is $cj->{'action'}, $e->action, sprintf("%s ->action = %s", $ct, $e->action);
                is $cj->{'listid'}, $e->listid, sprintf("%s ->listid = %s", $ct, $e->listid);

                is $cj->{'timestamp'},    $e->timestamp->epoch, sprintf("%s ->timestamp = %d", $ct, $cj->{'timestamp'});
                is $cj->{'destination'},  $e->recipient->host,  sprintf("%s ->destination = %s", $ct, $cj->{'destination'});
                is $cj->{'senderdomain'}, $e->addresser->host,  sprintf("%s ->senderdomain = %s", $ct, $cj->{'senderdomain'});

                isa_ok $cj->{'catch'}, 'HASH';
                is $cj->{'catch'}->{'from'}, $e->catch->{'from'}, sprintf("%s ->catch->from = %s", $ct, $e->catch->{'from'});
            };

            $ce += 1;
        }

        $ci += 1;
    }

    # Forwarded and bounced
    my $fw = Sisimai->rise('set-of-emails/maildir/bsd/lhost-sendmail-60.eml');
    isa_ok $fw, 'ARRAY';
    isa_ok $fw->[0], 'Sisimai::Fact';
    is $fw->[0]->alias, 'neko@libsisimai.org', '->alias = neko@libsisimai.org';
    is $fw->[0]->recipient->address, 'kijitora-cat@google.example.com', '->recipient = kijitora-cat@google.example.com';
}

done_testing;

