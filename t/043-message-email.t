use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Message;
use Sisimai::Message::Email;

my $PackageName = 'Sisimai::Message::Email';
my $MethodNames = {
    'class' => [
        'new', 'make', 'load', 'parse', 'divideup', 'headers', 'takeapart',
        'makeorder'
    ],
    'object' => ['from', 'header', 'ds', 'rfc822'],
};
my $SampleEmail = './set-of-emails/mailbox/mbox-0';

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    use IO::File;
    my $filehandle = IO::File->new($SampleEmail, 'r');
    my $mailastext = '';
    my $tobeloaded = $PackageName->load;
    my $callbackto = sub {
        my $argvs = shift;
        my $catch = { 
            'type' => $argvs->{'datasrc'},
            'x-mailer' => '',
            'return-path' => '',
        };
        $catch->{'from'} = $argvs->{'headers'}->{'from'} || '';
        $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
        $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
        return $catch;
    };

    while( my $r = <$filehandle> ) {
        $mailastext .= $r;
    }
    $filehandle->close;

    isa_ok $tobeloaded, 'ARRAY';
    ok length $mailastext;

    my $p = Sisimai::Message->new('data' => $mailastext, 'input' => 'email');

    isa_ok $p, 'Sisimai::Message';
    isa_ok $p->header, 'HASH', '->header';
    isa_ok $p->ds, 'ARRAY', '->ds';
    isa_ok $p->rfc822, 'HASH', '->rfc822';
    ok length $p->from, $p->from;

    $p = Sisimai::Message->new(
            'data' => $mailastext, 
            'hook' => $callbackto,
            'input' => 'email',
            'order' => [
                'Sisimai::MTA::Sendmail', 'Sisimai::MTA::Postfix', 
                'Sisimai::MTA::qmail', 'Sisimai::MTA::Exchange2003', 
                'Sisimai::MSP::US::Google', 'Sisimai::MSP::US::Verizon',
            ]
         );

    for my $e ( @{ $p->ds } ) {
        is $e->{'spec'}, 'SMTP', '->spec = SMTP';
        ok length $e->{'recipient'}, '->recipient = '.$e->{'recipient'};
        like $e->{'status'}, qr/\d[.]\d[.]\d+/, '->status = '.$e->{'status'};
        ok exists $e->{'command'}, '->command = '.$e->{'command'};
        ok length $e->{'date'}, '->date = '.$e->{'date'};
        ok length $e->{'diagnosis'}, '->diagnosis = '.$e->{'diagnosis'};
        ok length $e->{'action'}, '->action = '.$e->{'action'};
        ok length $e->{'rhost'}, '->rhost = '.$e->{'rhost'};
        ok length $e->{'lhost'}, '->lhost = '.$e->{'lhost'};

        for my $q ( 'rhost', 'lhost' ) {
            next unless $e->{ $q };
            like $e->{ $q }, qr/\A.+[.].+\z/, '->'.$q.' = '.$e->{ $q };
        }
        is $e->{'agent'}, 'MTA::Sendmail', '->agent = '.$e->{'agent'};
    }

    for my $e ( 'content-type', 'to', 'subject', 'date', 'from', 'message-id' ) {
        my $h = $p->header->{ $e };
        ok length $h, $h;
    }
    isa_ok $p->header->{'received'}, 'ARRAY';

    for my $e ( qw|return-path to subject date from message-id| ) {
        my $h = $p->rfc822->{ $e };
        ok length $h, $e;
    }

    isa_ok $p->catch, 'HASH';
    is $p->catch->{'type'}, 'email';
    ok defined $p->catch->{'x-mailer'};
    ok defined $p->catch->{'return-path'};
    ok defined $p->catch->{'from'};
}

done_testing;
