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

    my $file = './eg/maildir-as-a-sample/new/sendmail-3.eml';
    my $mail = Sisimai::Mail->new( $file );
    my $mesg = undef;
    my $data = undef;

    while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new( 'data' => $r ); 
        $data = Sisimai::Data->make( 'data' => $mesg ); 
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

            isa_ok $e->date, 'Time::Piece';
            is $e->date->year, 2014, 'date->year = '.$e->date->year;
            is $e->date->month, 'Jun', 'date->month = '.$e->date->month;
            is $e->date->mday, 21, 'date->mday = '.$e->date->mday;
            is $e->date->day, 'Sat', 'date->day = '.$e->date->day;

            ok length $e->provider, 'provider = '.$e->provider;
            ok length $e->category, 'category = '.$e->category;

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
            is $e->smtpagent, 'Sendmail', 'smtpagent = '.$e->smtpagent;
            is $e->smtpcommand, 'DATA', 'smtpcommand = '.$e->smtpcommand;

            ok length $e->diagnosticcode, 'diagnosticcode = '.$e->diagnosticcode;
            ok length $e->diagnostictype, 'diagnostictype = '.$e->diagnostictype;
            like $e->deliverystatus, qr/\A\d+[.]\d+[.]\d\z/, 'deliverystatus = '.$e->deliverystatus;
            like $e->timezoneoffset, qr/\A[+-]\d+\z/, 'timezoneoffset = '.$e->timezoneoffset;

            ok defined $e->feedbacktype, 'feedbacktype = '.$e->feedbacktype;
        }
    }

}

done_testing;
