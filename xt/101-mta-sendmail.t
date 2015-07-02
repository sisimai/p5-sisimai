use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MTA::Sendmail;

my $c = 'Sisimai::MTA::Sendmail';
my $d = './tmp/data/sendmail';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/suspend/,
    '01002' => qr/blocked/,
    '01003' => qr/expired/,
    '01004' => qr/userunknown/,
    '01005' => qr/expired/,
    '01006' => qr/expired/,
    '01007' => qr/expired/,
    '01008' => qr/filtered/,
    '01009' => qr/expired/,
    '01010' => qr/blocked/,
    '01011' => qr/blocked/,
    '01012' => qr/systemerror/,
    '01013' => qr/userunknown/,
    '01014' => qr/expired/,
    '01015' => qr/hostunknown/,
    '01016' => qr/expired/,
    '01017' => qr/expired/,
    '01018' => qr/hostunknown/,
    '01019' => qr/blocked/,
    '01020' => qr/expired/,
    '01021' => qr/expired/,
    '01022' => qr/expired/,
    '01023' => qr/expired/,
    '01024' => qr/filtered/,
    '01025' => qr/mesgtoobig/,
    '01026' => qr/blocked/,
    '01027' => qr/rejected/,
    '01028' => qr/norelaying/,
    '01029' => qr/spamdetected/,
    '01030' => qr/suspend/,
    '01031' => qr/suspend/,
    '01032' => qr/mailererror/,
    '01033' => qr/mailererror/,
    '01034' => qr/mailererror/,
    '01035' => qr/filtered/,
    '01036' => qr/filtered/,
    '01037' => qr/filtered/,
    '01038' => qr/userunknown/,
    '01039' => qr/(?:filtered|userunknown)/,
    '01040' => qr/userunknown/,
    '01041' => qr/userunknown/,
    '01042' => qr/userunknown/,
    '01043' => qr/userunknown/,
    '01044' => qr/userunknown/,
    '01045' => qr/userunknown/,
    '01046' => qr/userunknown/,
    '01047' => qr/blocked/,
    '01048' => qr/userunknown/,
    '01049' => qr/userunknown/,
    '01050' => qr/userunknown/,
    '01051' => qr/userunknown/,
    '01052' => qr/userunknown/,
    '01053' => qr/userunknown/,
    '01054' => qr/userunknown/,
    '01055' => qr/userunknown/,
    '01056' => qr/userunknown/,
    '01057' => qr/userunknown/,
    '01058' => qr/norelaying/,
    '01059' => qr/userunknown/,
    '01060' => qr/userunknown/,
    '01061' => qr/notaccept/,
    '01062' => qr/userunknown/,
    '01063' => qr/userunknown/,
    '01064' => qr/userunknown/,
    '01065' => qr/userunknown/,
    '01066' => qr/userunknown/,
    '01067' => qr/userunknown/,
    '01068' => qr/userunknown/,
    '01069' => qr/userunknown/,
    '01070' => qr/userunknown/,
    '01071' => qr/userunknown/,
    '01072' => qr/userunknown/,
    '01073' => qr/userunknown/,
    '01074' => qr/userunknown/,
    '01075' => qr/userunknown/,
    '01076' => qr/userunknown/,
    '01077' => qr/userunknown/,
    '01078' => qr/userunknown/,
    '01079' => qr/userunknown/,
    '01080' => qr/userunknown/,
    '01081' => qr/userunknown/,
    '01082' => qr/userunknown/,
    '01083' => qr/userunknown/,
    '01084' => qr/filtered/,
    '01085' => qr/filtered/,
    '01086' => qr/hostunknown/,
    '01087' => qr/hostunknown/,
    '01088' => qr/hostunknown/,
    '01089' => qr/norelaying/,
    '01090' => qr/filtered/,
    '01091' => qr/filtered/,
    '01092' => qr/filtered/,
    '01093' => qr/suspend/,
    '01094' => qr/mailboxfull/,
    '01095' => qr/mailboxfull/,
    '01096' => qr/mailboxfull/,
    '01097' => qr/mailboxfull/,
    '01098' => qr/mesgtoobig/,
    '01099' => qr/mesgtoobig/,
    '01100' => qr/mesgtoobig/,
    '01101' => qr/systemerror/,
    '01102' => qr/filtered/,
    '01103' => qr/filtered/,
    '01104' => qr/mesgtoobig/,
    '01105' => qr/mesgtoobig/,
    '01106' => qr/mesgtoobig/,
    '01107' => qr/systemerror/,
    '01108' => qr/systemerror/,
    '01109' => qr/filtered/,
    '01110' => qr/filtered/,
    '01111' => qr/networkerror/,
    '01112' => qr/mailererror/,
    '01113' => qr/contenterror/,
    '01114' => qr/securityerror/,
    '01115' => qr/securityerror/,
    '01116' => qr/securityerror/,
    '01117' => qr/spamdetected/,
    '01118' => qr/userunknown/,
    '01119' => qr/filtered/,
    '01120' => qr/filtered/,
    '01121' => qr/filtered/,
    '01122' => qr/userunknown/,
    '01123' => qr/userunknown/,
    '01124' => qr/expired/,
    '01125' => qr/mesgtoobig/,
    '01126' => qr/mailboxfull/,
    '01127' => qr/userunknown/,
    '01128' => qr/(?:rejected|filtered|userunknown|hostunknown|blocked)/,
    '01129' => qr/hasmoved/,
    '01130' => qr/userunknown/,
    '01131' => qr/filtered/,
    '01132' => qr/filtered/,
    '01133' => qr/filtered/,
    '01134' => qr/mesgtoobig/,
    '01135' => qr/userunknown/,
    '01136' => qr/hostunknown/,
    '01137' => qr/(?:userunknown|mailboxfull)/,
    '01138' => qr/filtered/,
    '01139' => qr/filtered/,
    '01140' => qr/filtered/,
    '01141' => qr/userunknown/,
    '01142' => qr/securityerror/,
    '01143' => qr/userunknown/,
    '01144' => qr/userunknown/,
    '01145' => qr/userunknown/,
    '01146' => qr/userunknown/,
    '01147' => qr/mesgtoobig/,
    '01148' => qr/userunknown/,
    '01149' => qr/userunknown/,
    '01150' => qr/userunknown/,
    '01151' => qr/mailboxfull/,
    '01152' => qr/systemerror/,
    '01153' => qr/mailererror/,
    '01154' => qr/userunknown/,
    '01155' => qr/mesgtoobig/,
    '01156' => qr/userunknown/,
    '01157' => qr/(?:hostunknown|filtered)/,
    '01158' => qr/expired/,
    '01159' => qr/mailboxfull/,
    '01160' => qr/filtered/,
    '01161' => qr/userunknown/,
    '01162' => qr/(?:userunknown|filtered)/,
    '01163' => qr/userunknown/,
    '01164' => qr/rejected/,
    '01165' => qr/mesgtoobig/,
    '01166' => qr/contenterror/,
    '01167' => qr/norelaying/,
    '01168' => qr/blocked/,
    '01169' => qr/securityerror/,
    '01170' => qr/blocked/,
    '01171' => qr/expired/,
    '01172' => qr/systemerror/,
    '01173' => qr/userunknown/,
    '01174' => qr/hostunknown/,
    '01175' => qr/blocked/,
    '01176' => qr/hasmoved/,
    '01177' => qr/mailererror/,
    '01178' => qr/hostunknown/,
    '01179' => qr/userunknown/,
    '01180' => qr/userunknown/,
    '01181' => qr/mesgtoobig/,
    '01182' => qr/userunknown/,
    '01183' => qr/suspend/,
    '01184' => qr/filtered/,
    '01185' => qr/expired/,
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

                ok length $f->deliverystatus, sprintf( "(%s) deliverystatus = %s", $e, $f->deliverystatus );
                like $f->reason, $ReturnValue->{ $emindex }, sprintf( "(%s) reason = %s", $e, $f->reason );

                isa_ok $f->timestamp, 'Sisimai::Time';
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
                is $f->smtpagent, [ split( '::', $c ) ]->[-1], sprintf( "(%s) smtpagent = %s", $e, $f->smtpagent );

                ok defined $f->feedbacktype, sprintf( "(%s) feedbacktype = ''", $e );
                ok defined $f->subject;
            }
        }
    }
    close $h;
}

done_testing;

