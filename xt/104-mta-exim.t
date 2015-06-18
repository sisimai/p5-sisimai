use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MTA::Exim;

my $c = 'Sisimai::MTA::Exim';
my $d = './tmp/data/exim';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/securityerror/,
    '01002' => qr/expired/,
    '01003' => qr/filtered/,
    '01004' => qr/blocked/,
    '01005' => qr/userunknown/,
    '01006' => qr/filtered/,
    '01007' => qr/securityerror/,
    '01008' => qr/userunknown/,
    '01009' => qr/hostunknown/,
    '01010' => qr/blocked/,
    '01011' => qr/userunknown/,
    '01012' => qr/userunknown/,
    '01013' => qr/userunknown/,
    '01014' => qr/expired/,
    '01015' => qr/expired/,
    '01016' => qr/userunknown/,
    '01017' => qr/expired/,
    '01018' => qr/userunknown/,
    '01019' => qr/userunknown/,
    '01020' => qr/userunknown/,
    '01021' => qr/filtered/,
    '01022' => qr/userunknown/,
    '01023' => qr/userunknown/,
    '01024' => qr/userunknown/,
    '01025' => qr/userunknown/,
    '01026' => qr/userunknown/,
    '01027' => qr/expired/,
    '01028' => qr/mailboxfull/,
    '01029' => qr/userunknown/,
    '01030' => qr/mailboxfull/,
    '01031' => qr/expired/,
    '01032' => qr/userunknown/,
    '01033' => qr/userunknown/,
    '01034' => qr/userunknown/,
    '01035' => qr/rejected/,
    '01036' => qr/userunknown/,
    '01037' => qr/expired/,
    '01038' => qr/blocked/,
    '01039' => qr/mailboxfull/,
    '01040' => qr/expired/,
    '01041' => qr/Delay/,
    'expired' => qr//,
    '01042' => qr/networkerror/,
    '01043' => qr/userunknown/,
    '01044' => qr/networkerror/,
    '01045' => qr/hostunknown/,
    '01046' => qr/userunknown/,
    '01047' => qr/userunknown/,
    '01048' => qr/userunknown/,
    '01049' => qr/suspend/,
    '01050' => qr/userunknown/,
    '01051' => qr/userunknown/,
    '01052' => qr/userunknown/,
    '01053' => qr/userunknown/,
    '01054' => qr/suspend/,
    '01055' => qr/userunknown/,
    '01056' => qr/userunknown/,
    '01057' => qr/suspend/,
    '01058' => qr/userunknown/,
    '01059' => qr/undefined/,
    '01060' => qr/expired/,
    '01061' => qr/userunknown/,
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
    '01073' => qr/suspend/,
    '01074' => qr/userunknown/,
    '01075' => qr/userunknown/,
    '01076' => qr/userunknown/,
    '01077' => qr/suspend/,
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

        next unless -f $emailfn;
        $mailbox = Sisimai::Mail->new( $emailfn );

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
                ok length $f->reason, sprintf( "(%s) reason = %s", $e, $f->reason );

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


