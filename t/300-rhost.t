use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai;
use Sisimai::Rhost;
use Sisimai::Reason;
use Module::Load;

my $Package = 'Sisimai::Rhost';
my $Methods = { 'class' => ['name', 'find'], 'object' => [] };
my $Classes = [qw|
    Aol Apple Cloudflare Cox Facebook FrancePTT GSuite GoDaddy Google IUA KDDI MessageLabs Microsoft
    Mimecast NTTDOCOMO Outlook Spectrum Tencent YahooInc
|];

MAKETEST: {
    use_ok $Package;
    can_ok $Package, @{ $Methods->{'class'} };
    is $Package->find, "";

    for my $e ( glob('./set-of-emails/maildir/bsd/rhost-*.eml') ) {
        my $v = Sisimai->rise($e);
        ok -f $e, $e;
        isa_ok $v, 'ARRAY';

        while( my $f = shift @$v ) {
            isa_ok $f, 'Sisimai::Fact';
            my $cv = $Package->name($f);

            ok length $cv, '->name = '.$cv;
            ok grep { $cv eq $_ } @$Classes;
        }
    }

    for my $e ( @$Classes ) {
        my $r = sprintf("%s::%s", $Package, $e);
        Module::Load::load $r;
        is $r->find(undef), "";
        is $r->find({'diagnosticcode' => '', 'replycode' => 10, 'deliverystatus' => ''}), '';
        is $r->find({'diagnosticcode' => 22, 'replycode' => 10, 'deliverystatus' => ''}), '';
        is $r->find({'diagnosticcode' => 22, 'replycode' => 10, 'deliverystatus' => 33}), '';
    }
}

done_testing;

