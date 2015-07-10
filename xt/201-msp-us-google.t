use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MSP::US::Google;

my $c = 'Sisimai::MSP::US::Google';
my $d = './tmp/data/us-google';
my $h = undef;
my $ReturnValue = {
    '01001' => qr/expired/,
    '01002' => qr/suspend/,
    '01003' => qr/expired/,
    '01004' => qr/filtered/,
    '01005' => qr/expired/,
    '01006' => qr/filtered/,
    '01007' => qr/userunknown/,
    '01008' => qr/expired/,
    '01009' => qr/expired/,
    '01010' => qr/userunknown/,
    '01011' => qr/mailboxfull/,
    '01012' => qr/expired/,
    '01013' => qr/mailboxfull/,
    '01014' => qr/userunknown/,
    '01015' => qr/filtered/,
    '01016' => qr/filtered/,
    '01017' => qr/filtered/,
    '01018' => qr/userunknown/,
    '01019' => qr/userunknown/,
    '01020' => qr/userunknown/,
    '01021' => qr/userunknown/,
    '01022' => qr/userunknown/,
    '01023' => qr/userunknown/,
    '01024' => qr/blocked/,
    '01025' => qr/filtered/,
    '01026' => qr/filtered/,
    '01027' => qr/blocked/,
    '01028' => qr/systemerror/,
    '01029' => qr/onhold/,
    '01030' => qr/blocked/,
    '01031' => qr/blocked/,
    '01032' => qr/expired/,
    '01033' => qr/blocked/,
    '01034' => qr/expired/,
    '01035' => qr/expired/,
    '01036' => qr/expired/,
    '01037' => qr/blocked/,
    '01038' => qr/userunknown/,
    '01039' => qr/userunknown/,
    '01040' => qr/(?:expired|undefined)/,
    '01041' => qr/userunknown/,
    '01042' => qr/userunknown/,
    '01043' => qr/userunknown/,
    '01044' => qr/securityerror/,
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
                is $f->smtpagent, [ split( '::', $c ) ]->[-2].'::'.[ split( '::', $c ) ]->[-1], sprintf( "(%s) smtpagent = %s", $e, $f->smtpagent );

                ok defined $f->subject;
            }
        }
    }
    close $h;
}

done_testing;

