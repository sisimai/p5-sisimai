use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;
use IO::File;

my $SampleEmails = [
    'email-domino-03.eml',
    'email-mfilter-04.eml',
];

MAKE_TEST: {
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

        my $p = Sisimai::Message->new('data' => $mailastext, 'hook' => $callbackto);
        isa_ok $p, 'Sisimai::Message';
        isa_ok $p->header, 'HASH', '->header';
        isa_ok $p->ds, 'ARRAY', '->ds';
        isa_ok $p->rfc822, 'HASH', '->rfc822';
        ok length $p->from, $p->from;

        isa_ok $p->catch, 'HASH';
        is $p->catch->{'passed'}, 1, '->catch->passed = 1';
        is $p->catch->{'base64'}, 0, '->catch->base64 = 0';
    }
}
done_testing;

