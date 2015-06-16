use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MTA::V5sendmail;

my $c = 'Sisimai::MTA::V5sendmail';
my $d = './tmp/data/v5sendmail';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/userunknown/,
    '01002' => qr/(?:userunknown|hostunknown)/,
    '01003' => qr/hostunknown/,
    '01004' => qr/hostunknown/,
    '01005' => qr/(?:userunknown|hostunknown)/,
    '01006' => qr/hostunknown/,
    '01007' => qr/(?:userunknown|hostunknown)/,
    '01008' => qr/hostunknown/,
    '01009' => qr/(?:hostunknown|userunknown)/,
    '01010' => qr/hostunknown/,
    '01011' => qr/hostunknown/,
    '01012' => qr/userunknown/,
    '01013' => qr/userunknown/,
    '01014' => qr/hostunknown/,
    '01015' => qr/hostunknown/,
    '01016' => qr/hostunknown/,
    '01017' => qr/userunknown/,
    '01018' => qr/(?:userunknown|hostunknown)/,
    '01019' => qr/filtered/,
    '01020' => qr/userunknown/,
    '01021' => qr/hostunknown/,
    '01022' => qr/(?:userunknown|hostunknown)/,
    '01023' => qr/hostunknown/,
    '01024' => qr/hostunknown/,
    '01025' => qr/hostunknown/,
    '01026' => qr/(?:hostunknown|userunknown)/,
    '01027' => qr/hostunknown/,
    '01028' => qr/(?:hostunknown|userunknown)/,
    '01029' => qr/(?:userunknown|hostunknown)/,
    '01030' => qr/hostunknown/,
    '01031' => qr/hostunknown/,
    '01032' => qr/userunknown/,
    '01033' => qr/(?:userunknown|hostunknown)/,
    '01034' => qr/hostunknown/,
    '01035' => qr/hostunknown/,
    '01036' => qr/userunknown/,
    '01037' => qr/hostunknown/,
    '01038' => qr/userunknown/,
    '01039' => qr/hostunknown/,
    '01040' => qr/hostunknown/,
    '01041' => qr/(?:userunknown|hostunknown)/,
    '01042' => qr/hostunknown/,
    '01043' => qr/(?:hostunknown|userunknown)/,
    '01044' => qr/hostunknown/,
    '01045' => qr/(?:hostunknown|userunknown)/,
    '01046' => qr/hostunknown/,
    '01047' => qr/hostunknown/,
    '01048' => qr/hostunknown/,
    '01049' => qr/userunknown/,
    '01050' => qr/hostunknown/,
    '01051' => qr/(?:hostunknown|userunknown)/,
    '01052' => qr/(?:blocked|hostunknown|userunknown)/,
    '01053' => qr/userunknown/,
    '01054' => qr/(?:hostunknown|userunknown)/,
    '01055' => qr/(?:hostunknown|userunknown)/,
    '01056' => qr/(?:userunknown|hostunknown)/,
    '01057' => qr/hostunknown/,
    '01058' => qr/userunknown/,
    '01059' => qr/hostunknown/,
    '01060' => qr/(?:hostunknown|userunknown)/,
    '01061' => qr/userunknown/,
    '01062' => qr/(?:hostunknown|userunknown)/,
    '01063' => qr/hostunknown/,
    '01064' => qr/(?:hostunknown|userunknown)/,
    '01065' => qr/hostunknown/,
    '01066' => qr/userunknown/,
    '01067' => qr/hostunknown/,
    '01068' => qr/hostunknown/,
    '01069' => qr/filtered/,
    '01070' => qr/hostunknown/,
    '01071' => qr/hostunknown/,
    '01072' => qr/(?:hostunknown|userunknown)/,
    '01073' => qr/(?:hostunknown|userunknown)/,
    '01074' => qr/(?:systemerror|userunknown)/,
    '01075' => qr/hostunknown/,
    '01076' => qr/(?:hostunknown|userunknown)/,
    '01077' => qr/hostunknown/,
    '01078' => qr/hostunknown/,
    '01079' => qr/hostunknown/,
    '01080' => qr/hostunknown/,
    '01081' => qr/(?:hostunknown|userunknown)/,
    '01082' => qr/userunknown/,
    '01083' => qr/hostunknown/,
    '01084' => qr/hostunknown/,
    '01085' => qr/hostunknown/,
    '01086' => qr/hostunknown/,
    '01087' => qr/(?:userunknown|hostunknown)/,
    '01088' => qr/hostunknown/,
    '01089' => qr/hostunknown/,
    '01090' => qr/(?:hostunknown|userunknown)/,
    '01091' => qr/hostunknown/,
    '01092' => qr/hostunknown/,
    '01093' => qr/hostunknown/,
    '01094' => qr/(?:userunknown|hostunknown)/,
    '01095' => qr/(?:userunknown|hostunknown)/,
    '01096' => qr/(?:userunknown|hostunknown)/,
    '01097' => qr/(?:userunknown|hostunknown)/,
    '01098' => qr/userunknown/,
    '01099' => qr/(?:hostunknown|userunknown|blocked)/,
    '01100' => qr/userunknown/,
    '01101' => qr/hostunknown/,
    '01102' => qr/hostunknown/,
    '01103' => qr/hostunknown/,
    '01104' => qr/userunknown/,
    '01105' => qr/hostunknown/,
    '01106' => qr/userunknown/,
    '01107' => qr/userunknown/,
    '01108' => qr/hostunknown/,
    '01109' => qr/hostunknown/,
    '01110' => qr/hostunknown/,
    '01111' => qr/userunknown/,
    '01112' => qr/userunknown/,
    '01113' => qr/blocked/,
    '01114' => qr/hostunknown/,
    '01115' => qr/networkerror/,
    '01116' => qr/hostunknown/,
    '01117' => qr/blocked/,
    '01118' => qr/(?:hostunknown|userunknown)/,
    '01119' => qr/expired/,
    '01120' => qr/(?:userunknown|hostunknown)/,
    '01121' => qr/hostunknown/,
    '01122' => qr/blocked/,
    '01123' => qr/hostunknown/,
    '01124' => qr/expired/,
    '01125' => qr/expired/,
    '01126' => qr/(?:userunknown|hostunknown)/,
    '01127' => qr/expired/,
    '01128' => qr/securityerror/,
    '01129' => qr/hostunknown/,
    '01130' => qr/expired/,
    '01131' => qr/(?:userunknown|hostunknown)/,
    '01132' => qr/filtered/,
    '01133' => qr/hostunknown/,
    '01134' => qr/expired/,
    '01135' => qr/hostunknown/,
    '01136' => qr/hostunknown/,
    '01137' => qr/(?:userunknown|hostunknown)/,
    '01138' => qr/userunknown/,
    '01139' => qr/(?:userunknown|hostunknown)/,
    '01140' => qr/(?:hostunknown|userunknown)/,
    '01141' => qr/hostunknown/,
    '01142' => qr/(?:systemerror|userunknown)/,
    '01143' => qr/hostunknown/,
    '01144' => qr/(?:hostunknown|userunknown)/,
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
                is $f->smtpagent, [ split( '::', $c ) ]->[-1], sprintf( "(%s) smtpagent = %s", $e, $f->smtpagent );

                ok defined $f->feedbacktype, sprintf( "(%s) feedbacktype = ''", $e );
                ok defined $f->subject;
            }
        }
    }
    close $h;
}

done_testing;


