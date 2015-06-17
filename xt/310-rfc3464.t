use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC3464;

my $c = 'Sisimai::RFC3464';
my $d = './tmp/data/rfc3464';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/expired/,
    '01002' => qr/userunknown/,
    '01003' => qr/mesgtoobig/,
    '01004' => qr/filtered/,
    '01005' => qr/networkerror/,
    '01006' => qr/filtered/,
    '01007' => qr/undefined/,
    '01008' => qr/expired/,
    '01009' => qr/userunknown/,
    '01010' => qr/undefined/,
    '01011' => qr/hostunknown/,
    '01012' => qr/filtered/,
    '01013' => qr/filtered/,
    '01014' => qr/userunknown/,
    '01015' => qr/hostunknown/,
    '01016' => qr/userunknown/,
    '01017' => qr/userunknown/,
    '01018' => qr/userunknown/,
    '01019' => qr/filtered/,
    '01020' => qr/userunknown/,
    '01021' => qr/filtered/,
    '01022' => qr/userunknown/,
    '01023' => qr/filtered/,
    '01024' => qr/filtered/,
    '01025' => qr/filtered/,
    '01026' => qr/filtered/,
    '01027' => qr/filtered/,
    '01028' => qr/filtered/,
    '01029' => qr/filtered/,
    '01030' => qr/blocked/,
    '01031' => qr/userunknown/,
    '01032' => qr/filtered/,
    '01033' => qr/userunknown/,
    '01034' => qr/filtered/,
    '01035' => qr/userunknown/,
    '01036' => qr/filtered/,
    '01037' => qr/systemerror/,
    '01038' => qr/filtered/,
    '01039' => qr/hostunknown/,
    '01040' => qr/networkerror/,
    '01041' => qr/filtered/,
    '01042' => qr/filtered/,
    '01043' => qr/(?:filtered|undefined)/,
    '01044' => qr/userunknown/,
    '01045' => qr/userunknown/,
    '01046' => qr/userunknown/,
    '01047' => qr/undefined/,
    '01048' => qr/filtered/,
    '01049' => qr/userunknown/,
    '01050' => qr/filtered/,
    '01051' => qr/userunknown/,
    '01052' => qr/undefined/,
    '01053' => qr/mailererror/,
    '01054' => qr/undefined/,
    '01055' => qr/userunknown/,
    '01056' => qr/mailboxfull/,
    '01057' => qr/filtered/,
    '01058' => qr/undefined/,
    '01059' => qr/userunknown/,
    '01060' => qr/filtered/,
    '01061' => qr/hasmoved/,
    '01062' => qr/userunknown/,
    '01063' => qr/filtered/,
    '01064' => qr/filtered/,
    '01065' => qr/spamdetected/,
    '01066' => qr/filtered/,
    '01067' => qr/systemerror/,
    '01068' => qr/undefined/,
    '01069' => qr/expired/,
    '01070' => qr/userunknown/,
    '01071' => qr/mailboxfull/,
    '01072' => qr/filtered/,
    '01073' => qr/filtered/,
    '01074' => qr/filtered/,
    '01075' => qr/filtered/,
    '01076' => qr/systemerror/,
    '01077' => qr/filtered/,
    '01078' => qr/userunknown/,
    '01079' => qr/filtered/,
    '01080' => qr/filtered/,
    '01081' => qr/(?:filtered|undefined)/,
    '01082' => qr/mailboxfull/,
    '01083' => qr/filtered/,
    '01084' => qr/mailboxfull/,
    '01085' => qr/filtered/,
    '01086' => qr/filtered/,
    '01087' => qr/filtered/,
    '01088' => qr/undefined/,
    '01089' => qr/filtered/,
    '01090' => qr/filtered/,
    '01091' => qr/undefined/,
    '01092' => qr/undefined/,
    '01093' => qr/filtered/,
    '01094' => qr/filtered/,
    '01095' => qr/filtered/,
    '01096' => qr/filtered/,
    '01097' => qr/filtered/,
    '01098' => qr/filtered/,
    '01099' => qr/securityerror/,
    '01100' => qr/securityerror/,
    '01101' => qr/filtered/,
    '01102' => qr/filtered/,
    '01103' => qr/expired/,
    '01104' => qr/filtered/,
    '01105' => qr/filtered/,
    '01106' => qr/expired/,
    '01107' => qr/filtered/,
    '01108' => qr/undefined/,
    '01109' => qr/undefined/,
    '01110' => qr/userunknown/,
    '01111' => qr/mailboxfull/,
    '01112' => qr/filtered/,
    '01113' => qr/filtered/,
    '01114' => qr/systemerror/,
    '01115' => qr/expired/,
    '01116' => qr/mailboxfull/,
    '01117' => qr/mesgtoobig/,
    '01118' => qr/expired/,
    '01119' => qr/spamdetected/,
    '01120' => qr/filtered/,
    '01121' => qr/expired/,
    '01122' => qr/filtered/,
    '01123' => qr/expired/,
    '01124' => qr/mailererror/,
    '01125' => qr/networkerror/,
    '01126' => qr/userunknown/,
    '01127' => qr/filtered/,
    '01128' => qr/(?:systemerror|undefined)/,
    '01129' => qr/userunknown/,
    '01130' => qr/systemerror/,
    '01131' => qr/userunknown/,
    '01132' => qr/systemerror/,
    '01133' => qr/systemerror/,
    '01134' => qr/filtered/,
    '01135' => qr/userunknown/,
    '01136' => qr/undefined/,
    '01137' => qr/spamdetected/,
    '01138' => qr/userunknown/,
    '01139' => qr/undefined/,
    '01140' => qr/filtered/,
    '01141' => qr/userunknown/,
    '01142' => qr/filtered/,
    '01143' => qr/undefined/,
    '01144' => qr/filtered/,
    '01145' => qr/undefined/,
    '01146' => qr/mailboxfull/,
    '01147' => qr/spamdetected/,
    '01148' => qr/mailboxfull/,
    '01149' => qr/expired/,
    '01150' => qr/mailboxfull/,
    '01151' => qr/mesgtoobig/,
    '01152' => qr/mesgtoobig/,
    '01153' => qr/undefined/,
    '01154' => qr/userunknown/,
    '01155' => qr/networkerror/,
    '01156' => qr/spamdetected/,
    '01157' => qr/filtered/,
    '01158' => qr/(?:expired|undefined)/,
    '01159' => qr/mailboxfull/,
    '01160' => qr/filtered/,
    '01161' => qr/mailererror/,
    '01162' => qr/filtered/,
    '01163' => qr/mesgtoobig/,
    '01164' => qr/userunknown/,
    '01165' => qr/networkerror/,
    '01166' => qr/systemerror/,
    '01167' => qr/hostunknown/,
    '01168' => qr/mailboxfull/,
    '01169' => qr/userunknown/,
    '01170' => qr/undefined/,
    '01171' => qr/undefined/,
    '01172' => qr/mailboxfull/,
    '01173' => qr/networkerror/,
    '01174' => qr/expired/,
    '01175' => qr/filtered/,
    '01176' => qr/filtered/,
    '01177' => qr/(?:filtered|undefined)/,
    '01178' => qr/filtered/,
    '01179' => qr/userunknown/,
    '01180' => qr/mailboxfull/,
    '01181' => qr/filtered/,
    '01182' => qr/undefined/,
    '01183' => qr/mailboxfull/,
    '01184' => qr/undefined/,
    '01185' => qr/networkerror/,
    '01186' => qr/networkerror/,
    '01187' => qr/userunknown/,
    '01188' => qr/userunknown/,
    '01189' => qr/userunknown/,
    '01190' => qr/userunknown/,
    '01191' => qr/userunknown/,
    '01192' => qr/userunknown/,
    '01193' => qr/userunknown/,
    '01194' => qr/userunknown/,
    '01195' => qr/blocked/,
    '01196' => qr/userunknown/,
    '01197' => qr/userunknown/,
    '01198' => qr/userunknown/,
    '01199' => qr/userunknown/,
    '01200' => qr/userunknown/,
    '01201' => qr/userunknown/,
    '01202' => qr/userunknown/,
    '01203' => qr/userunknown/,
    '01204' => qr/userunknown/,
    '01205' => qr/userunknown/,
    '01206' => qr/userunknown/,
    '01207' => qr/securityerror/,
    '01208' => qr/userunknown/,
    '01209' => qr/userunknown/,
    '01210' => qr/userunknown/,
    '01211' => qr/userunknown/,
    '01212' => qr/mailboxfull/,
    '01213' => qr/spamdetected/,
    '01214' => qr/spamdetected/,
    '01215' => qr/spamdetected/,
    '01216' => qr/undefined/,
    '01217' => qr/userunknown/,
    '01218' => qr/mailboxfull/,
    '01219' => qr/userunknown/,
    '01220' => qr/filtered/,
    '01221' => qr/filtered/,
    '01222' => qr/mailboxfull/,
    '01223' => qr/mailboxfull/,
    '01224' => qr/filtered/,
    '01225' => qr/expired/,
    '01226' => qr/filtered/,
    '01227' => qr/userunknown/,
    '01228' => qr/undefined/,
    '01229' => qr/filtered/,
    '01230' => qr/filtered/,
    '01231' => qr/filtered/,
    '01232' => qr/networkerror/,
    '01233' => qr/mailererror/,
    '01234' => qr/filtered/,
    '01235' => qr/mailboxfull/,
};
use_ok $c;

if( -d $d ) {
    use Sisimai::Mail;
    use Sisimai::Data;
    use Sisimai::Message;
    use Sisimai::Address;

    opendir( $h, $d );
    while( my $e = readdir $h ) {

        my $emailfn = sprintf( "%s/%s", $d, $e );
        my $mailbox = undef;
        my $emindex = $e;

        next unless -f $emailfn;
        $mailbox =  Sisimai::Mail->new( $emailfn );
        $emindex =~ s/\A(\d+)[-].*[.]eml/$1/;

        while( my $r = $mailbox->read ) {

            my $p = Sisimai::Message->new( 'data' => $r );
            my $v = Sisimai::Data->make( 'data' => $p );
            my $t = undef;

            for my $f ( @$v ) {
                isa_ok $f, 'Sisimai::Data';

                ok length $f->token, sprintf( "(%s) token = %s", $e, $f->token );
                ok defined $f->lhost, sprintf( "(%s) lhost = %s", $e, $f->lhost );
                ok defined $f->rhost, sprintf( "(%s) rhost = %s", $e, $f->rhost );

                ok defined $f->listid, sprintf( "(%s) listid = %s", $e, $f->listid );
                ok defined $f->alias, sprintf( "(%s) alias = %s", $e, $f->alias );

                ok defined $f->deliverystatus, sprintf( "(%s) deliverystatus = %s", $e, $f->deliverystatus );
                like $f->reason, $ReturnValue->{ $emindex }, sprintf( "(%s) reason = %s", $e, $f->reason );

                isa_ok $f->timestamp, 'Time::Piece';
                $t = $f->timestamp;
                like $t->year, qr/\A\d{4}\z/, sprintf( "(%s) timestamp->year = %s", $e, $t->year );
                like $t->month, qr/\A\w+\z/, sprintf( "(%s) timestamp->month = %s", $e, $t->month );
                like $t->mday, qr/\A\d+\z/, sprintf( "(%s) timestamp->mday = %s", $e, $t->mday );
                like $t->day, qr/\A\w+\z/, sprintf( "(%s) timestamp->day = %s", $e, $t->day );

                ok defined $f->messageid, sprintf( "(%s) messageid = %s", $e, $f->messageid );
                ok defined $f->smtpcommand, sprintf( "(%s) smtpcommand = %s", $e, $f->smtpcommand );
                ok defined $f->diagnosticcode, sprintf( "(%s) diagnosticcode = %s", $e, $f->diagnosticcode );

                isa_ok $f->addresser, 'Sisimai::Address';
                $t = $f->addresser;
                ok length $t->host, sprintf( "(%s) addresser->host = %s", $e, $t->host );
                ok length $t->user, sprintf( "(%s) addresser->user = %s", $e, $t->user );
                ok length $t->address, sprintf( "(%s) addresser->address = %s", $e, $t->address );
                is $t->host, $f->senderdomain, sprintf( "(%s) senderdomain = %s", $e, $f->senderdomain );

                isa_ok $f->recipient, 'Sisimai::Address';
                $t = $f->recipient;
                ok length $t->host, sprintf( "(%s) recipient->host = %s", $e, $t->host );
                ok length $t->user, sprintf( "(%s) recipient->user = %s", $e, $t->user );
                ok length $t->address, sprintf( "(%s) recipient->address = %s", $e, $t->address );
                is $t->host, $f->destination, sprintf( "(%s) destination = %s", $e, $f->destination );

                like $f->timezoneoffset, qr/\A[+-]\d+\z/, sprintf( "(%s) timezoneoffset = %s", $e, $f->timezoneoffset );
                ok length $f->smtpagent, sprintf( "(%s) smtpagent = %s", $e, $f->smtpagent );

                ok defined $f->feedbacktype, sprintf( "(%s) feedbacktype = %s", $e,$f->feedbacktype );
                ok defined $f->subject;
            }
        }
    }
    close $h;
}

done_testing;

