use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MTA::qmail;

my $c = 'Sisimai::MTA::qmail';
my $d = './tmp/data/qmail';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/filtered/,
    '01002' => qr/undefined/,
    '01003' => qr/hostunknown/,
    '01004' => qr/userunknown/,
    '01005' => qr/hostunknown/,
    '01006' => qr/userunknown/,
    '01007' => qr/hostunknown/,
    '01008' => qr/userunknown/,
    '01009' => qr/userunknown/,
    '01010' => qr/hostunknown/,
    '01011' => qr/hostunknown/,
    '01012' => qr/userunknown/,
    '01013' => qr/userunknown/,
    '01014' => qr/rejected/,
    '01015' => qr/rejected/,
    '01016' => qr/hostunknown/,
    '01017' => qr/userunknown/,
    '01018' => qr/userunknown/,
    '01019' => qr/mailboxfull/,
    '01020' => qr/filtered/,
    '01021' => qr/userunknown/,
    '01022' => qr/userunknown/,
    '01023' => qr/filtered/,
    '01024' => qr/filtered/,
    '01025' => qr/(?:userunknown|filtered)/,
    '01026' => qr/mesgtoobig/,
    '01027' => qr/mailboxfull/,
    '01028' => qr/userunknown/,
    '01029' => qr/filtered/,
    '01030' => qr/userunknown/,
    '01031' => qr/filtered/,
    '01032' => qr/networkerror/,
    '01033' => qr/mailboxfull/,
    '01034' => qr/mailboxfull/,
    '01035' => qr/mailboxfull/,
    '01036' => qr/userunknown/,
    '01037' => qr/hostunknown/,
    '01038' => qr/filtered/,
    '01039' => qr/mailboxfull/,
    '01040' => qr/mailboxfull/,
    '01041' => qr/userunknown/,
    '01042' => qr/(?:userunknown|filtered)/,
    '01043' => qr/rejected/,
    '01044' => qr/blocked/,
    '01045' => qr/systemerror/,
    '01046' => qr/mailboxfull/,
    '01047' => qr/userunknown/,
    '01048' => qr/mailboxfull/,
    '01049' => qr/mailboxfull/,
    '01050' => qr/userunknown/,
    '01051' => qr/undefined/,
    '01052' => qr/suspend/,
    '01053' => qr/filtered/,
    '01054' => qr/filtered/,
    '01055' => qr/mailboxfull/,
    '01056' => qr/userunknown/,
    '01057' => qr/filtered/,
    '01058' => qr/userunknown/,
    '01059' => qr/filtered/,
    '01060' => qr/suspend/,
    '01061' => qr/filtered/,
    '01062' => qr/filtered/,
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


