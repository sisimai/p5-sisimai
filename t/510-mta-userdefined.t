use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;

my $PackageName = 'Sisimai::Data';
my $MethodNames = {
    'class' => [ 'new', 'make' ],
    'object' => [ 'damn' ],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->make, undef;
    is $PackageName->new, undef;

    my $file = './set-of-emails/mailbox/mbox-1';
    my $mail = Sisimai::Mail->new( $file );
    my $mesg = undef;
    my $data = undef;
    my $list = undef;

    while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new( 
                    'data' => $r,
                    'load' => [ 'Sisimai::MTA::UserDefined' ]
                ); 
        $data = Sisimai::Data->make( 'data' => $mesg ); 
        isa_ok $data, 'ARRAY';

        for my $e ( @$data ) {
            isa_ok $e, $PackageName;
            ok defined $e->token, 'token = '.$e->token;
            ok defined $e->lhost, 'lhost = '.$e->lhost;
            ok defined $e->rhost, 'rhost = '.$e->rhost;
            ok defined $e->listid, 'listid = '.$e->listid;
            ok defined $e->messageid, 'messageid = '.$e->messageid;
            ok defined $e->smtpcommand, 'smtpcommand = '.$e->smtpcommand;

            is $e->reason, 'userunknown', 'reason = '.$e->reason;
            is $e->smtpagent, 'Module name', 'smtpagent = '.$e->smtpagent;

            isa_ok $e->timestamp, 'Sisimai::Time';
            is $e->timestamp->year, 2010, 'timestamp->year = '.$e->timestamp->year;
            is $e->timestamp->month, 'Apr', 'timestamp->month = '.$e->timestamp->month;
            is $e->timestamp->mday, 29, 'timestamp->mday = '.$e->timestamp->mday;
            is $e->timestamp->day, 'Thu', 'timestamp->day = '.$e->timestamp->day;

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

            ok length $e->subject, 'subject = '.$e->subject;
            ok length $e->softbounce, 'softbounce = '.$e->softbounce;
            ok length $e->diagnosticcode, 'diagnosticcode = '.$e->diagnosticcode;
            ok length $e->diagnostictype, 'diagnostictype = '.$e->diagnostictype;
            like $e->deliverystatus, qr/\A\d+[.]\d+[.]\d\z/, 'deliverystatus = '.$e->deliverystatus;
            like $e->timezoneoffset, qr/\A[+-]\d+\z/, 'timezoneoffset = '.$e->timezoneoffset;
            like $e->replycode, qr/\A[2345][0-5][0-9]\z/, 'replycode = '.$e->replycode;

            ok defined $e->feedbacktype, 'feedbacktype = '.$e->feedbacktype;
            ok defined $e->action, 'action = '.$e->action;
        }
    }
}
done_testing;
