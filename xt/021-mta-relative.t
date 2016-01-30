use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $X = qr/\A(?:dovecot|mail[.]local|procmail|maildrop|vpopmail|vmailmgr|RFC3464)/;
my $R = {
    'ARF' => {
        '01001' => qr/feedback/,
        '01002' => qr/feedback/,
        '01003' => qr/feedback/,
        '01004' => qr/feedback/,
        '01005' => qr/feedback/,
        '01006' => qr/feedback/,
        '01007' => qr/feedback/,
        '01008' => qr/feedback/,
        '01009' => qr/feedback/,
        '01010' => qr/feedback/,
        '01011' => qr/feedback/,
        '01012' => qr/feedback/,
        '01013' => qr/feedback/,
        '01014' => qr/feedback/,
        '01015' => qr/feedback/,
    },
    'RFC3464' => {
        '01001' => qr/expired/,
        '01002' => qr/userunknown/,
        '01003' => qr/mesgtoobig/,
        '01004' => qr/filtered/,
        '01005' => qr/networkerror/,
        '01007' => qr/onhold/,
        '01008' => qr/expired/,
        '01009' => qr/userunknown/,
        '01011' => qr/hostunknown/,
        '01013' => qr/filtered/,
        '01014' => qr/userunknown/,
        '01015' => qr/hostunknown/,
        '01016' => qr/userunknown/,
        '01017' => qr/userunknown/,
        '01018' => qr/mailboxfull/,
        '01019' => qr/filtered/,
        '01020' => qr/userunknown/,
        '01021' => qr/filtered/,
        '01022' => qr/userunknown/,
        '01023' => qr/filtered/,
        '01024' => qr/userunknown/,
        '01025' => qr/filtered/,
        '01026' => qr/filtered/,
        '01027' => qr/filtered/,
        '01029' => qr/filtered/,
        '01031' => qr/userunknown/,
        '01033' => qr/userunknown/,
        '01035' => qr/userunknown/,
        '01036' => qr/filtered/,
        '01037' => qr/systemerror/,
        '01038' => qr/filtered/,
        '01039' => qr/hostunknown/,
        '01040' => qr/networkerror/,
        '01041' => qr/filtered/,
        '01042' => qr/filtered/,
        '01043' => qr/(?:filtered|onhold)/,
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
        '01055' => qr/filtered/,
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
        '01081' => qr/(?:filtered|onhold)/,
        '01083' => qr/filtered/,
        '01085' => qr/filtered/,
        '01086' => qr/filtered/,
        '01087' => qr/filtered/,
        '01088' => qr/onhold/,
        '01089' => qr/filtered/,
        '01090' => qr/filtered/,
        '01091' => qr/undefined/,
        '01092' => qr/undefined/,
        '01093' => qr/filtered/,
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
        '01109' => qr/onhold/,
        '01111' => qr/mailboxfull/,
        '01112' => qr/filtered/,
        '01113' => qr/filtered/,
        '01114' => qr/systemerror/,
        '01115' => qr/expired/,
        '01116' => qr/mailboxfull/,
        '01117' => qr/mesgtoobig/,
        '01118' => qr/expired/,
        '01120' => qr/filtered/,
        '01121' => qr/expired/,
        '01122' => qr/filtered/,
        '01123' => qr/expired/,
        '01124' => qr/mailererror/,
        '01125' => qr/networkerror/,
        '01126' => qr/userunknown/,
        '01127' => qr/filtered/,
        '01128' => qr/(?:systemerror|onhold)/,
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
        '01139' => qr/expired/,
        '01140' => qr/filtered/,
        '01141' => qr/userunknown/,
        '01142' => qr/filtered/,
        '01143' => qr/undefined/,
        '01144' => qr/filtered/,
        '01145' => qr/mailboxfull/,
        '01146' => qr/mailboxfull/,
        '01148' => qr/mailboxfull/,
        '01149' => qr/expired/,
        '01150' => qr/mailboxfull/,
        '01151' => qr/exceedlimit/,
        '01152' => qr/exceedlimit/,
        '01153' => qr/onhold/,
        '01154' => qr/userunknown/,
        '01155' => qr/networkerror/,
        '01156' => qr/spamdetected/,
        '01157' => qr/filtered/,
        '01158' => qr/(?:expired|onhold)/,
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
        '01170' => qr/onhold/,
        '01171' => qr/onhold/,
        '01172' => qr/mailboxfull/,
        '01173' => qr/networkerror/,
        '01174' => qr/expired/,
        '01175' => qr/filtered/,
        '01176' => qr/filtered/,
        '01177' => qr/(?:filtered|onhold)/,
        '01178' => qr/filtered/,
        '01179' => qr/userunknown/,
        '01180' => qr/mailboxfull/,
        '01181' => qr/filtered/,
        '01182' => qr/onhold/,
        '01183' => qr/mailboxfull/,
        '01184' => qr/(?:undefined|onhold)/,
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
        '01195' => qr/norelaying/,
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
        '01216' => qr/onhold/,
        '01217' => qr/userunknown/,
        '01218' => qr/mailboxfull/,
        '01219' => qr/onhold/,
        '01220' => qr/filtered/,
        '01221' => qr/filtered/,
        '01222' => qr/mailboxfull/,
        '01223' => qr/mailboxfull/,
        '01224' => qr/filtered/,
        '01225' => qr/expired/,
        '01226' => qr/filtered/,
        '01227' => qr/userunknown/,
        '01228' => qr/onhold/,
        '01229' => qr/filtered/,
        '01230' => qr/filtered/,
        '01231' => qr/filtered/,
        '01232' => qr/networkerror/,
        '01233' => qr/mailererror/,
        '01234' => qr/(?:filtered|onhold)/,
        '01235' => qr/filtered/,
        '01236' => qr/userunknown/,
        '01237' => qr/userunknown/,
        '01238' => qr/userunknown/,
        '01239' => qr/userunknown/,
        '01240' => qr/userunknown/,
        '01241' => qr/userunknown/,
        '01242' => qr/userunknown/,
        '01243' => qr/onhold/,
        '01244' => qr/mailboxfull/,
        '01245' => qr/mailboxfull/,
        '01246' => qr/userunknown/,
        '01247' => qr/userunknown/,
        '01248' => qr/mailboxfull/,
        '01249' => qr/onhold/,
    },
    'RFC3834' => {
        '01002' => qr/vacation/,
    },
};

for my $x ( keys %$R ) {
    # Check each MTA module
    my $M = 'Sisimai::'.$x;
    my $d = './set-of-emails/private/'.lc($x);

    Module::Load::load( $M );
    use_ok $M;

    if( -d $d ) {

        my $h = undef;
        my $n = 0;
        ok $d, sprintf( "%s %s", $x, $d );

        opendir( $h, $d );
        while( my $e = readdir $h ) {
            # Open email in set-of-emails/private directory
            next if $e eq '.';
            next if $e eq '..';

            my $emailfn = sprintf( "%s/%s", $d, $e ); next unless -f $emailfn;
            my $mailbox = Sisimai::Mail->new( $emailfn );

            $n = $e; $n =~ s/\A(\d+)[-].*[.]eml/$1/;

            while( my $r = $mailbox->read ) {
                # Parse each email in set-of-emails/ directory
                ok length $r;

                my $p = Sisimai::Message->new( 'data' => $r );
                my $v = Sisimai::Data->make( 'data' => $p );
                my $y = undef;

                # is ref($p), 'Sisimai::Message', sprintf( "[%s] %s/%s(Sisimai::Message)", $n, $e, $x );
                # is ref($v), 'ARRAY', sprintf( "[%s] %s/%s(ARRAY)", $n, $e, $x );
                # ok scalar @$v, sprintf( "[%s] %s/%s(%d)", $n, $e, $x, scalar @$v );

                for my $ee ( @$v ) {
                    isa_ok $ee, 'Sisimai::Data';

                    ok length $ee->token,          sprintf( "[%s] %s/%s->token = %s", $n, $e, $x, $ee->token );

                    ok defined $ee->lhost, sprintf( "[%s] %s/%s->lhost = %s", $n, $e, $x, $ee->lhost );
                    ok defined $ee->rhost, sprintf( "[%s] %s/%s->rhost = %s", $n, $e, $x, $ee->rhost );
                    ok defined $ee->alias, sprintf( "[%s] %s/%s->alias = %s", $n, $e, $x, $ee->alias );
                    ok defined $ee->listid,sprintf( "[%s] %s/%s->listid = %s",$n, $e, $x, $ee->listid );
                    ok defined $ee->action,sprintf( "[%s] %s/%s->action = %s",$n, $e, $x, $ee->action );

                    ok defined $ee->messageid,     sprintf( "[%s] %s/%s->messageid = %s", $n, $e, $x, $ee->messageid );
                    ok defined $ee->smtpcommand,   sprintf( "[%s] %s/%s->smtpcommand = %s", $n, $e, $x, $ee->smtpcommand );
                    ok defined $ee->diagnosticcode,sprintf( "[%s] %s/%s->diagnosticcode = %s", $n, $e, $x, $ee->diagnosticcode );
                    ok defined $ee->diagnostictype,sprintf( "[%s] %s/%s->diagnostictype = %s", $n, $e, $x, $ee->diagnostictype );
                    ok defined $ee->replycode,     sprintf( "[%s] %s/%s->replycode = %s", $n, $e, $x, $ee->replycode );
                    ok defined $ee->feedbacktype,  sprintf( "[%s] %s/%s->feedbacktype = %s", $n, $e, $x, $ee->feedbacktype );
                    ok defined $ee->subject,       sprintf( "[%s] %s/%s->subject", $n, $e, $x );

                    if( $x eq 'ARF' || $x eq 'RFC3834' ) {
                        ok defined $ee->deliverystatus,sprintf( "[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus );
                    } else {
                        ok length  $ee->deliverystatus,sprintf( "[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus );
                    }

                    if( $x eq 'RFC3464' ) {
                        # Sisimai::RFC3464
                        like $ee->smtpagent, $X, sprintf( "[%s] %s/%s->smtpagent = %s", $n, $e, $x, $ee->smtpagent );

                    } elsif( $x eq 'ARF' ) {
                        # Sisimai::ARF
                        ok $ee->smtpagent,           sprintf( "[%s] %s/%s->smtpagent = %s", $n, $e, $x, $ee->smtpagent );
                        ok length $ee->feedbacktype, sprintf( "[%s] %s/%s->feedbacktype = %s", $n, $e, $x, $ee->feedbacktype );
                    }

                    if( length $ee->action ) {
                        # Check the value of action
                        like $ee->action, qr/(?:fail.+|delayed|expired)\z/, 
                            sprintf( "[%s] %s/%s->action = %s", $n, $e, $x, $ee->action );
                    }

                    if( length $ee->deliverystatus ) {
                        # Check the value of D.S.N. format
                        like $ee->deliverystatus, qr/\A[45][.]\d/, 
                            sprintf( "[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus );

                        if( substr( $ee->deliverystatus, 0, 1 ) == 4 ) {
                            # 4.x.x
                            is $ee->softbounce, 1, sprintf( "[%s] %s/%s->softbounce = %s", $n, $e, $x, $ee->softbounce );

                        } elsif( substr( $ee->deliverystatus, 0, 1 ) == 5 ) {
                            # 5.x.x
                            is $ee->softbounce, 0, sprintf( "[%s] %s/%s->softbounce = %s", $n, $e, $x, $ee->softbounce );
                        }
                    } else {
                        # No deliverystatus
                        is $ee->softbounce, -1, sprintf( "[%s] %s/%s->softbounce = %s", $n, $e, $x, $ee->softbounce );
                    }

                    like $ee->reason,         $R->{ $x }->{ $n },   sprintf( "[%s] %s/%s->reason = %s", $n, $e, $x, $ee->reason );
                    like $ee->replycode,      qr/\A(?:[45]\d\d|)\z/,sprintf( "[%s] %s/%s->replycode = %s", $n, $e, $x, $ee->replycode );
                    like $ee->timezoneoffset, qr/\A[+-]\d+\z/,      sprintf( "[%s] %s/%s->timezoneoffset = %s", $n, $e, $x, $ee->timezoneoffset );

                    unlike $ee->deliverystatus,qr/[ ]/, sprintf( "[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus );
                    unlike $ee->smtpcommand,   qr/[ ]/, sprintf( "[%s] %s/%s->smtpcommand = %s", $n, $e, $x, $ee->smtpcommand );

                    unlike $ee->lhost,     qr/[ ]/, sprintf( "[%s] %s/%s->lhost = %s", $n, $e, $x, $ee->lhost );
                    unlike $ee->rhost,     qr/[ ]/, sprintf( "[%s] %s/%s->rhost = %s", $n, $e, $x, $ee->rhost );
                    unlike $ee->alias,     qr/[ ]/, sprintf( "[%s] %s/%s->alias = %s", $n, $e, $x, $ee->alias );
                    unlike $ee->listid,    qr/[ ]/, sprintf( "[%s] %s/%s->listid = %s", $n, $e, $x, $ee->listid );
                    unlike $ee->action,    qr/[ ]/, sprintf( "[%s] %s/%s->action = %s", $n, $e, $x, $ee->action );
                    unlike $ee->messageid, qr/[ ]/, sprintf( "[%s] %s/%s->messageid = %s", $n, $e, $x, $ee->messageid );

                    isa_ok $ee->timestamp, 'Sisimai::Time'; $y = $ee->timestamp;
                    like $y->year, qr/\A\d{4}\z/,sprintf( "[%s] %s/%s->timestamp->year = %s", $n, $e, $x, $y->year );
                    like $y->month,qr/\A\w+\z/,  sprintf( "[%s] %s/%s->timestamp->month = %s", $n, $e, $x, $y->month );
                    like $y->mday, qr/\A\d+\z/,  sprintf( "[%s] %s/%s->timestamp->mday = %s", $n, $e, $x, $y->mday );
                    like $y->day,  qr/\A\w+\z/,  sprintf( "[%s] %s/%s->timestamp->day = %s", $n, $e, $x, $y->day );

                    isa_ok $ee->addresser, 'Sisimai::Address'; $y = $ee->addresser;
                    ok length  $y->host,            sprintf( "[%s] %s/%s->addresser->host = %s", $n, $e, $x, $y->host );
                    ok length  $y->user,            sprintf( "[%s] %s/%s->addresser->user = %s", $n, $e, $x, $y->user );
                    ok length  $y->address,         sprintf( "[%s] %s/%s->addresser->address = %s", $n, $e, $x, $y->address );
                    ok defined $y->verp,            sprintf( "[%s] %s/%s->addresser->verp = %s", $n, $e, $x, $y->verp );
                    ok defined $y->alias,           sprintf( "[%s] %s/%s->addresser->alias = %s", $n, $e, $x, $y->alias );

                    is $y->host, $ee->senderdomain, sprintf( "[%s] %s/%s->senderdomain = %s", $n, $e, $x, $y->host );
                    unlike $y->host,   qr/[ ]/,     sprintf( "[%s] %s/%s->addresser->host = %s", $n, $e, $x, $y->host );
                    unlike $y->user,   qr/[ ]/,     sprintf( "[%s] %s/%s->addresser->user = %s", $n, $e, $x, $y->user );
                    unlike $y->verp,   qr/[ ]/,     sprintf( "[%s] %s/%s->addresser->verp = %s", $n, $e, $x, $y->verp );
                    unlike $y->alias,  qr/[ ]/,     sprintf( "[%s] %s/%s->addresser->alias = %s", $n, $e, $x, $y->alias );
                    unlike $y->address,qr/[ ]/,     sprintf( "[%s] %s/%s->addresser->address = %s", $n, $e, $x, $y->address );

                    isa_ok $ee->recipient, 'Sisimai::Address'; $y = $ee->recipient;
                    ok length  $y->host,            sprintf( "[%s] %s/%s->recipient->host = %s", $n, $e, $x, $y->host );
                    ok length  $y->user,            sprintf( "[%s] %s/%s->recipient->user = %s", $n, $e, $x, $y->user );
                    ok length  $y->address,         sprintf( "[%s] %s/%s->recipient->address = %s", $n, $e, $x, $y->address );
                    ok defined $y->verp,            sprintf( "[%s] %s/%s->recipient->verp = %s", $n, $e, $x, $y->verp );
                    ok defined $y->alias,           sprintf( "[%s] %s/%s->recipient->alias = %s", $n, $e, $x, $y->alias );

                    is $y->host, $ee->destination,  sprintf( "[%s] %s/%s->destination = %s", $n, $e, $x, $y->host );
                    unlike $y->host,   qr/[ ]/,     sprintf( "[%s] %s/%s->recipient->host = %s", $n, $e, $x, $y->host );
                    unlike $y->user,   qr/[ ]/,     sprintf( "[%s] %s/%s->recipient->user = %s", $n, $e, $x, $y->user );
                    unlike $y->verp,   qr/[ ]/,     sprintf( "[%s] %s/%s->recipient->verp = %s", $n, $e, $x, $y->verp );
                    unlike $y->alias,  qr/[ ]/,     sprintf( "[%s] %s/%s->recipient->alias = %s", $n, $e, $x, $y->alias );
                    unlike $y->address,qr/[ ]/,     sprintf( "[%s] %s/%s->recipient->address = %s", $n, $e, $x, $y->address );

                }
            }
        }
        close $h;
    }
}
done_testing;


