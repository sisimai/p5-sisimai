use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MTA::Postfix;

my $c = 'Sisimai::MTA::Postfix';
my $d = './tmp/data/postfix';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/filtered/,
    '01002' => qr/userunknown/,
    '01003' => qr/userunknown/,
    '01004' => qr/userunknown/,
    '01005' => qr/filtered/,
    '01006' => qr/userunknown/,
    '01007' => qr/filtered/,
    '01008' => qr/filtered/,
    '01009' => qr/userunknown/,
    '01010' => qr/hostunknown/,
    '01011' => qr/systemerror/,
    '01012' => qr/userunknown/,
    '01013' => qr/userunknown/,
    '01014' => qr/userunknown/,
    '01015' => qr/userunknown/,
    '01016' => qr/toomanyconn/,
    '01017' => qr/expired/,
    '01018' => qr/systemerror/,
    '01019' => qr/userunknown/,
    '01020' => qr/userunknown/,
    '01021' => qr/expired/,
    '01022' => qr/userunknown/,
    '01023' => qr/blocked/,
    '01024' => qr/userunknown/,
    '01025' => qr/userunknown/,
    '01026' => qr/expired/,
    '01027' => qr/systemerror/,
    '01028' => qr/suspend/,
    '01029' => qr/userunknown/,
    '01030' => qr/userunknown/,
    '01031' => qr/userunknown/,
    '01032' => qr/userunknown/,
    '01033' => qr/userunknown/,
    '01034' => qr/filtered/,
    '01035' => qr/mailboxfull/,
    '01036' => qr/hostunknown/,
    '01037' => qr/filtered/,
    '01038' => qr/blocked/,
    '01039' => qr/userunknown/,
    '01040' => qr/userunknown/,
    '01041' => qr/userunknown/,
    '01042' => qr/networkerror/,
    '01043' => qr/hasmoved/,
    '01044' => qr/mesgtoobig/,
    '01045' => qr/mesgtoobig/,
    '01046' => qr/mesgtoobig/,
    '01047' => qr/mesgtoobig/,
    '01048' => qr/userunknown/,
    '01049' => qr/hostunknown/,
    '01050' => qr/userunknown/,
    '01051' => qr/blocked/,
    '01052' => qr/spamdetected/,
    '01053' => qr/systemerror/,
    '01054' => qr/userunknown/,
    '01055' => qr/filtered/,
    '01056' => qr/mailererror/,
    '01057' => qr/userunknown/,
    '01058' => qr/filtered/,
    '01059' => qr/userunknown/,
    '01060' => qr/userunknown/,
    '01061' => qr/hostunknown/,
    '01062' => qr/filtered/,
    '01063' => qr/mailererror/,
    '01064' => qr/hostunknown/,
    '01065' => qr/networkerror/,
    '01066' => qr/norelaying/,
    '01067' => qr/userunknown/,
    '01068' => qr/norelaying/,
    '01069' => qr/userunknown/,
    '01070' => qr/networkerror/,
    '01071' => qr/mailboxfull/,
    '01072' => qr/undefined/,
    '01073' => qr/mailboxfull/,
    '01074' => qr/mailboxfull/,
    '01075' => qr/mailboxfull/,
    '01076' => qr/filtered/,
    '01077' => qr/norelaying/,
    '01078' => qr/norelaying/,
    '01079' => qr/spamdetected/,
    '01080' => qr/spamdetected/,
    '01081' => qr/spamdetected/,
    '01082' => qr/spamdetected/,
    '01083' => qr/spamdetected/,
    '01084' => qr/spamdetected/,
    '01085' => qr/spamdetected/,
    '01086' => qr/spamdetected/,
    '01087' => qr/spamdetected/,
    '01088' => qr/spamdetected/,
    '01089' => qr/spamdetected/,
    '01090' => qr/spamdetected/,
    '01091' => qr/spamdetected/,
    '01092' => qr/spamdetected/,
    '01093' => qr/spamdetected/,
    '01094' => qr/spamdetected/,
    '01095' => qr/spamdetected/,
    '01096' => qr/spamdetected/,
    '01097' => qr/spamdetected/,
    '01098' => qr/spamdetected/,
    '01099' => qr/spamdetected/,
    '01100' => qr/spamdetected/,
    '01101' => qr/securityerror/,
    '01102' => qr/spamdetected/,
    '01103' => qr/spamdetected/,
    '01104' => qr/spamdetected/,
    '01105' => qr/spamdetected/,
    '01106' => qr/spamdetected/,
    '01107' => qr/spamdetected/,
    '01108' => qr/spamdetected/,
    '01109' => qr/spamdetected/,
    '01110' => qr/spamdetected/,
    '01111' => qr/spamdetected/,
    '01112' => qr/spamdetected/,
    '01113' => qr/spamdetected/,
    '01114' => qr/spamdetected/,
    '01115' => qr/blocked/,
    '01116' => qr/spamdetected/,
    '01117' => qr/spamdetected/,
    '01118' => qr/spamdetected/,
    '01119' => qr/spamdetected/,
    '01120' => qr/spamdetected/,
    '01121' => qr/spamdetected/,
    '01122' => qr/hostunknown/,
    '01123' => qr/userunknown/,
    '01124' => qr/userunknown/,
    '01125' => qr/exceedlimit/,
    '01126' => qr/systemerror/,
    '01127' => qr/userunknown/,
    '01128' => qr/userunknown/,
    '01129' => qr/filtered/,
    '01130' => qr/mailboxfull/,
    '01131' => qr/exceedlimit/,
    '01132' => qr/userunknown/,
    '01133' => qr/userunknown/,
    '01134' => qr/userunknown/,
    '01135' => qr/suspend/,
    '01136' => qr/userunknown/,
    '01137' => qr/userunknown/,
    '01138' => qr/userunknown/,
    '01139' => qr/userunknown/,
    '01140' => qr/userunknown/,
    '01141' => qr/filtered/,
    '01142' => qr/blocked/,
    '01143' => qr/userunknown/,
    '01144' => qr/suspend/,
    '01145' => qr/filtered/,
    '01146' => qr/userunknown/,
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
                ok defined $f->replycode, '->replycode = '.$f->replycode;

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


