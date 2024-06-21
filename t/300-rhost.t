use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use Sisimai::Rhost;
use Sisimai::Reason;
use Module::Load;

my $Package = 'Sisimai::Rhost';
my $Methods = { 'class' => ['get'], 'object' => [] };
my $Classes = [qw|
    Apple Cox FrancePTT GoDaddy Google IUA KDDI Microsoft Mimecast NTTDOCOMO Spectrum Tencent YahooInc
|];

MAKETEST: {
    use_ok $Package;
    can_ok $Package, @{ $Methods->{'class'} };
    is $Package->get, undef;

    for my $e ( glob('./set-of-emails/maildir/bsd/rhost-*.eml') ) {
        my $v = Sisimai->rise($e);
        ok -f $e, $e;
        isa_ok $v, 'ARRAY';

        while( my $f = shift @$v ) {
            isa_ok $f, 'Sisimai::Fact';
            ok length $f->rhost, '->rhost = '.$f->rhost;
            ok length $f->reason, '->reason = '.$f->reason;

            my $cx = $f->damn;
            ok length $cx->{'destination'};
            is $Package->get($cx, $cx->{'destination'}), $f->reason, sprintf("->damn->reason = %s", $f->reason);
        }
    }

    for my $e ( @$Classes ) {
        my $r = sprintf("%s::%s", $Package, $e);
        Module::Load::load $r;
        is $r->get(undef), undef;
        is $r->get({'diagnosticcode' => '', 'replycode' => 10, 'deliverystatus' => ''}), '';
        is $r->get({'diagnosticcode' => 22, 'replycode' => 10, 'deliverystatus' => ''}), '';
        is $r->get({'diagnosticcode' => 22, 'replycode' => 10, 'deliverystatus' => 33}), '';
    }
}

done_testing;

