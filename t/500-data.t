use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;

my $PackageName = 'Sisimai::Data';
my $MethodNames = {
    'class' => ['new', 'make'],
    'object' => ['damn'],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->make, undef;
    is $PackageName->new, undef;

    my $file = './set-of-emails/maildir/bsd/mta-sendmail-03.eml';
    my $mail = Sisimai::Mail->new($file);
    my $mesg = undef;
    my $data = undef;
    my $list = undef;
    my $call = sub {
        my $argvs = shift;
        my $catch = { 
            'from' => '',
            'x-mailer' => '',
            'return-path' => '',
        };
        $catch->{'type'} = $argvs->{'datasrc'};
        $catch->{'from'} = $argvs->{'headers'}->{'from'} || '';
        $catch->{'x-mailer'}    = $1 if $argvs->{'message'} =~ m/^X-Mailer:\s*(.*)$/m;
        $catch->{'return-path'} = $1 if $argvs->{'message'} =~ m/^Return-Path:\s*(.+)$/m;
        return $catch;
    };

    while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new('data' => $r, 'hook' => $call); 
        $data = Sisimai::Data->make('data' => $mesg); 
        isa_ok $data, 'ARRAY';

        for my $e ( @$data ) {
            isa_ok $e, $PackageName;
            ok length $e->token, 'token = '.$e->token;
            ok length $e->lhost, 'lhost = '.$e->lhost;
            ok length $e->rhost, 'rhost = '.$e->rhost;
            like $e->alias, qr/\A.+[@].+[.].+\z/, 'alias = '.$e->alias;
            ok defined $e->listid, 'listid = '.$e->listid;
            is $e->reason, 'userunknown', 'reason = '.$e->reason;
            ok length $e->subject, 'subject = '.$e->subject;

            isa_ok $e->timestamp, 'Sisimai::Time';
            is $e->timestamp->year, 2014, 'timestamp->year = '.$e->timestamp->year;
            is $e->timestamp->month, 'Jun', 'timestamp->month = '.$e->timestamp->month;
            is $e->timestamp->mday, 21, 'timestamp->mday = '.$e->timestamp->mday;
            is $e->timestamp->day, 'Sat', 'timestamp->day = '.$e->timestamp->day;

            isa_ok $e->addresser, 'Sisimai::Address';
            ok length $e->addresser->host, 'addresser->host = '.$e->addresser->host;
            ok length $e->addresser->user, 'addresser->user = '.$e->addresser->user;
            ok length $e->addresser->address, 'addresser->address = '.$e->addresser->address;
            is $e->addresser->host, $e->senderdomain, 'senderdomain = '.$e->senderdomain;

            isa_ok $e->recipient, 'Sisimai::Address';
            ok length $e->recipient->host, 'recipient->host = '.$e->recipient->host;
            ok length $e->recipient->user, 'recipient->user = '.$e->recipient->user;
            ok length $e->recipient->address, 'recipient->address = '.$e->recipient->address;
            is $e->recipient->host, $e->destination, 'destination = '.$e->destination;

            ok length $e->messageid, 'messageid = '.$e->messageid;
            like $e->messageid, qr/\A.+[@].+/, 'messageid = '.$e->messageid;

            is $e->smtpagent, 'Email::Sendmail', 'smtpagent = '.$e->smtpagent;
            is $e->smtpcommand, 'DATA', 'smtpcommand = '.$e->smtpcommand;

            ok length $e->diagnosticcode, 'diagnosticcode = '.$e->diagnosticcode;
            ok length $e->diagnostictype, 'diagnostictype = '.$e->diagnostictype;
            is $e->diagnostictype, 'SMTP', 'diagnostictype = '.$e->diagnostictype;

            like $e->deliverystatus, qr/\A\d+[.]\d+[.]\d\z/, 'deliverystatus = '.$e->deliverystatus;
            like $e->timezoneoffset, qr/\A[+-]\d+\z/, 'timezoneoffset = '.$e->timezoneoffset;
            like $e->replycode, qr/\A[2345][0-5][0-9]\z/, 'replycode = '.$e->replycode;

            ok length $e->softbounce, 'softbounce = '.$e->softbounce;
            ok $e->softbounce > -1,   'softbounce = '.$e->softbounce;

            ok defined $e->feedbacktype, 'feedbacktype = '.$e->feedbacktype;
            ok defined $e->action, 'action = '.$e->action;

            isa_ok $e->catch, 'HASH';
            is $e->catch->{'type'}, 'email';
            ok length $e->catch->{'x-mailer'};
            like $e->catch->{'x-mailer'}, qr/Apple/;
            ok length $e->catch->{'return-path'};
            like $e->catch->{'return-path'}, qr/kijitora/;
            ok length $e->catch->{'from'};
            like $e->catch->{'from'}, qr/[@]/;
        }
    }

    $file = './set-of-emails/maildir/bsd/mta-sendmail-04.eml';
    $mail = Sisimai::Mail->new($file);
    $list = { 
        'recipient' => ['X-Failed-Recipient', 'To'],
        'addresser' => ['Return-Path', 'From', 'X-Envelope-From'],
    };

    WITH_ORDER: while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new('data' => $r); 
        $data = Sisimai::Data->make('data' => $mesg, 'order' => $list); 
        isa_ok $data, 'ARRAY';

        for my $e ( @$data ) {
            isa_ok $e, $PackageName;
            ok length $e->token, 'token = '.$e->token;
            ok length $e->lhost, 'lhost = '.$e->lhost;
            unlike $e->lhost, qr/[ ]/, '->lhost = '.$e->lhost;

            ok length $e->rhost, 'rhost = '.$e->rhost;
            unlike $e->rhost, qr/[ ]/, '->rhost = '.$e->rhost;

            ok defined $e->listid, 'listid = '.$e->listid;
            unlike $e->listid, qr/[ ]/, '->listid = '.$e->listid;

            is $e->reason, 'rejected', 'reason = '.$e->reason;
            ok length $e->subject, 'subject = '.$e->subject;

            isa_ok $e->timestamp, 'Sisimai::Time';
            is $e->timestamp->year, 2009, 'timestamp->year = '.$e->timestamp->year;
            is $e->timestamp->month, 'Apr', 'timestamp->month = '.$e->timestamp->month;
            is $e->timestamp->mday, 29, 'timestamp->mday = '.$e->timestamp->mday;
            is $e->timestamp->day, 'Wed', 'timestamp->day = '.$e->timestamp->day;

            isa_ok $e->addresser, 'Sisimai::Address';
            ok length $e->addresser->host, 'addresser->host = '.$e->addresser->host;
            ok length $e->addresser->user, 'addresser->user = '.$e->addresser->user;
            ok length $e->addresser->address, 'addresser->address = '.$e->addresser->address;
            is $e->addresser->host, $e->senderdomain, 'senderdomain = '.$e->destination;

            isa_ok $e->recipient, 'Sisimai::Address';
            ok length $e->recipient->host, 'recipient->host = '.$e->recipient->host;
            ok length $e->recipient->user, 'recipient->user = '.$e->recipient->user;
            ok length $e->recipient->address, 'recipient->address = '.$e->recipient->address;
            is $e->recipient->host, $e->destination, 'destination = '.$e->destination;

            ok length $e->messageid, 'messageid = '.$e->messageid;
            unlike $e->messageid, qr/[ ]/, '->messageid = '.$e->messageid;

            is $e->smtpagent, 'Email::Sendmail', 'smtpagent = '.$e->smtpagent;
            is $e->smtpcommand, 'MAIL', 'smtpcommand = '.$e->smtpcommand;

            ok length $e->diagnosticcode, 'diagnosticcode = '.$e->diagnosticcode;
            ok length $e->diagnostictype, 'diagnostictype = '.$e->diagnostictype;
            like $e->deliverystatus, qr/\A\d+[.]\d+[.]\d\z/, 'deliverystatus = '.$e->deliverystatus;
            like $e->timezoneoffset, qr/\A[+-]\d+\z/, 'timezoneoffset = '.$e->timezoneoffset;
            like $e->replycode, qr/\A[2345][0-5][0-9]\z/, 'replycode = '.$e->replycode;

            ok defined $e->feedbacktype, 'feedbacktype = '.$e->feedbacktype;
        }
    }

    $file = './set-of-emails/maildir/not/is-not-bounce-01.eml';
    $mail = Sisimai::Mail->new($file);

    NOT_BOUNCE: while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new('data' => $r); 
        is $mesg, undef;
    }
}
done_testing;
