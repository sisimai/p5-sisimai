use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MSP::JP::EZweb;

my $c = 'Sisimai::MSP::JP::EZweb';
my $d = './tmp/data/jp-ezweb';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/userunknown/,
    '01002' => qr/filtered/,
    '01003' => qr/userunknown/,
    '01004' => qr/userunknown/,
    '01005' => qr/suspend/,
    '01006' => qr/filtered/,
    '01007' => qr/suspend/,
    '01008' => qr/filtered/,
    '01009' => qr/filtered/,
    '01010' => qr/filtered/,
    '01011' => qr/filtered/,
    '01012' => qr/filtered/,
    '01013' => qr/expired/,
    '01014' => qr/filtered/,
    '01015' => qr/suspend/,
    '01016' => qr/filtered/,
    '01017' => qr/filtered/,
    '01018' => qr/filtered/,
    '01019' => qr/suspend/,
    '01020' => qr/filtered/,
    '01021' => qr/filtered/,
    '01022' => qr/filtered/,
    '01023' => qr/suspend/,
    '01024' => qr/filtered/,
    '01025' => qr/filtered/,
    '01026' => qr/filtered/,
    '01027' => qr/filtered/,
    '01028' => qr/filtered/,
    '01029' => qr/suspend/,
    '01030' => qr/filtered/,
    '01031' => qr/suspend/,
    '01032' => qr/filtered/,
    '01033' => qr/mailboxfull/,
    '01034' => qr/filtered/,
    '01035' => qr/suspend/,
    '01036' => qr/mailboxfull/,
    '01037' => qr/userunknown/,
    '01038' => qr/suspend/,
    '01039' => qr/suspend/,
    '01040' => qr/suspend/,
    '01041' => qr/suspend/,
    '01042' => qr/suspend/,
    '01043' => qr/suspend/,
    '01044' => qr/userunknown/,
    '01045' => qr/filtered/,
    '01046' => qr/filtered/,
    '01047' => qr/filtered/,
    '01048' => qr/suspend/,
    '01049' => qr/filtered/,
    '01050' => qr/suspend/,
    '01051' => qr/filtered/,
    '01052' => qr/suspend/,
    '01053' => qr/filtered/,
    '01054' => qr/suspend/,
    '01055' => qr/filtered/,
    '01056' => qr/userunknown/,
    '01057' => qr/filtered/,
    '01058' => qr/suspend/,
    '01059' => qr/suspend/,
    '01060' => qr/filtered/,
    '01061' => qr/suspend/,
    '01062' => qr/filtered/,
    '01063' => qr/userunknown/,
    '01064' => qr/filtered/,
    '01065' => qr/suspend/,
    '01066' => qr/filtered/,
    '01067' => qr/filtered/,
    '01068' => qr/suspend/,
    '01069' => qr/suspend/,
    '01070' => qr/suspend/,
    '01071' => qr/filtered/,
    '01072' => qr/suspend/,
    '01073' => qr/filtered/,
    '01074' => qr/filtered/,
    '01075' => qr/suspend/,
    '01076' => qr/filtered/,
    '01077' => qr/expired/,
    '01078' => qr/filtered/,
    '01079' => qr/filtered/,
    '01080' => qr/filtered/,
    '01081' => qr/filtered/,
    '01082' => qr/filtered/,
    '01083' => qr/filtered/,
    '01084' => qr/filtered/,
    '01085' => qr/expired/,
    '01086' => qr/filtered/,
    '01087' => qr/filtered/,
    '01088' => qr/(?:mailboxfull|suspend)/,
    '01089' => qr/filtered/,
    '01090' => qr/suspend/,
    '01091' => qr/filtered/,
    '01092' => qr/filtered/,
    '01093' => qr/suspend/,
    '01094' => qr/userunknown/,
    '01095' => qr/filtered/,
    '01096' => qr/filtered/,
    '01097' => qr/filtered/,
    '01098' => qr/suspend/,
    '01099' => qr/filtered/,
    '01100' => qr/filtered/,
    '01101' => qr/filtered/,
    '01102' => qr/suspend/,
    '01103' => qr/userunknown/,
    '01104' => qr/filtered/,
    '01105' => qr/filtered/,
    '01106' => qr/userunknown/,
    '01107' => qr/filtered/,
    '01108' => qr/userunknown/,
    '01109' => qr/userunknown/,
    '01110' => qr/filtered/,
    '01111' => qr/suspend/,
    '01112' => qr/suspend/,
    '01113' => qr/suspend/,
    '01114' => qr/filtered/,
    '01115' => qr/suspend/,
    '01116' => qr/filtered/,
    '01117' => qr/(?:filtered|suspend)/,
    '01118' => qr/suspend/,
    '01119' => qr/filtered/,
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

                ok defined $f->lhost, sprintf( "(%s) lhost = %s", $e, $f->lhost );
                ok defined $f->rhost, sprintf( "(%s) rhost = %s", $e, $f->rhost );
                ok defined $f->listid, sprintf( "(%s) listid = %s", $e, $f->listid );
                ok defined $f->alias, sprintf( "(%s) alias = %s", $e, $f->alias );

                ok length $f->deliverystatus, sprintf( "(%s) deliverystatus = %s", $e, $f->deliverystatus );
                ok length $f->token, sprintf( "(%s) token = %s", $e, $f->token );
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
                is $f->smtpagent, [ split( '::', $c ) ]->[-2].'::'.[ split( '::', $c ) ]->[-1], sprintf( "(%s) smtpagent = %s", $e, $f->smtpagent );

                ok defined $f->subject;
            }
        }
    }
    close $h;
}

done_testing;

