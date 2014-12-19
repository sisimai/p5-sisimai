use strict;
use Test::More;
use lib qw(./lib ./blib/lib);

my $PackageName = 'Sisimai::Data::YAML';
my $MethodNames = {
    'class' => [ 'dump' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    is $PackageName->dump('yaml'), undef;

    use Sisimai::Data;
    use Sisimai::Mail;
    use Sisimai::Message;
    use Try::Tiny;
    my $test = 0;

    try {
        Module::Load::load('YAML1');
        ok 'YAML', 'YAML module is installed';
        $test = 1;

    } catch {
        ok 'YAML', 'YAML module is not installed';
    };

    if( $test ) {

        my $file = './eg/maildir-as-a-sample/new/sendmail-02.eml';
        my $mail = Sisimai::Mail->new( $file );
        my $mesg = undef;
        my $data = undef;
        my $list = undef;
        my $yaml = undef;
        my $perl = undef;

        while( my $r = $mail->read ){ 
            $mesg = Sisimai::Message->new( 'data' => $r ); 
            $data = Sisimai::Data->make( 'data' => $mesg ); 
            isa_ok $data, 'ARRAY';

            for my $e ( @$data ) {

                $yaml = $e->dump('yaml');
                ok length $yaml, '->dump()';

                utf8::encode $yaml if utf8::is_utf8 $yaml;
                $perl = YAML::Load( $yaml );
                isa_ok $perl, 'HASH';

                is $e->token, $perl->{'token'}, 'token = '.$e->token;
                is $e->lhost, $perl->{'lhost'}, 'lhost = '.$e->lhost;
                is $e->rhost, $perl->{'rhost'}, 'rhost = '.$e->rhost;
                is $e->alias, $perl->{'alias'}, 'alias = '.$e->alias;

                is $e->listid, $perl->{'listid'}, 'listid = '.$e->listid;
                is $e->reason, $perl->{'reason'}, 'reason = '.$e->reason;

                utf8::decode $perl->{'subject'} unless utf8::is_utf8 $perl->{'subject'};
                is $e->subject, $perl->{'subject'};
                is $e->timestamp->epoch, $perl->{'timestamp'}, 'timestamp->epoch = '.$e->timestamp->epoch;

                is $e->addresser->address, $perl->{'addresser'}, 'addresser->address = '.$e->addresser->address;
                is $e->addresser->host, $perl->{'senderdomain'}, 'senderdomain = '.$e->senderdomain;
                is $e->recipient->address, $perl->{'recipient'}, 'recipient->address = '.$e->recipient->address;
                is $e->recipient->host, $perl->{'destination'}, 'destination = '.$e->destination;

                is $e->messageid, $perl->{'messageid'}, 'messageid = '.$e->messageid;
                is $e->smtpagent, $perl->{'smtpagent'}, 'smtpagent = '.$e->smtpagent;
                is $e->smtpcommand, $perl->{'smtpcommand'}, 'smtpcommand = '.$e->smtpcommand;

                is $e->diagnosticcode, $perl->{'diagnosticcode'}, 'diagnosticcode = '.$e->diagnosticcode;
                is $e->diagnostictype, $perl->{'diagnostictype'}, 'diagnostictype = '.$e->diagnostictype;
                is $e->deliverystatus, $perl->{'deliverystatus'}, 'deliverystatus = '.$e->deliverystatus;
                is $e->timezoneoffset, $perl->{'timezoneoffset'}, 'timezoneoffset = '.$e->timezoneoffset;

                is $e->feedbacktype, $perl->{'feedbacktype'}, 'feedbacktype = '.$e->feedbacktype;
                is $e->action, $perl->{'action'}, 'action = '.$e->action;
            }
        }
    }
}
done_testing;


