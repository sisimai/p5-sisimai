use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Fact;
use IO::File;

my $SampleEmails = ['lhost-domino-03.eml', 'lhost-mfilter-04.eml'];

MAKETEST: {
    my $callbackto = sub {
        my $argvs = shift;
        my $catch = { 'passed' => 0, 'base64' => 0 };

        for my $v ( split(/\n/, $argvs->{'message'}) ) {
            next unless $v =~ m|\A[0-9A-Za-z=/]{32,64}\z|;
            $catch->{'base64'} = 1;
            last;
        }
        $catch->{'passed'} = 1;
        return $catch;
    };

    for my $e ( @$SampleEmails ) {
        my $filehandle = IO::File->new('set-of-emails/maildir/bsd/'.$e, 'r');
        my $mailastext = '';

        while( my $r = <$filehandle> ) {
            $mailastext .= $r;
        }
        $filehandle->close;
        ok length $mailastext;

        my $p = shift @{ Sisimai::Fact->rise({ 'data' => $mailastext, 'hook' => $callbackto }) };
        isa_ok $p, 'Sisimai::Fact';

        isa_ok $p->catch, 'HASH';
        is $p->catch->{'passed'}, 1, '->catch->passed = 1';
        is $p->catch->{'base64'}, 0, '->catch->base64 = 0';
    }
}
done_testing;

