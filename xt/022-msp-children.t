use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $R = {
    'DE::EinsUndEins' => {
        '01001' => qr/undefined/,
        '01002' => qr/undefined/,
    },
    'DE::GMX' => {
        '01001' => qr/expired/,
        '01002' => qr/userunknown/,
        '01003' => qr/mailboxfull/,
        '01004' => qr/(?:userunknown|mailboxfull)/,
    },
    'JP::Biglobe' => {
        '01001' => qr/mailboxfull/,
        '01002' => qr/mailboxfull/,
        '01003' => qr/mailboxfull/,
        '01004' => qr/mailboxfull/,
        '01005' => qr/filtered/,
        '01006' => qr/filtered/,
    },
    'JP::EZweb' => {
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
    },
    'JP::KDDI' => {
        '01001' => qr/mailboxfull/,
        '01002' => qr/mailboxfull/,
        '01003' => qr/mailboxfull/,
    },
    'RU::MailRu' => {
        '01001' => qr/userunknown/,
        '01002' => qr/userunknown/,
        '01003' => qr/mailboxfull/,
        '01004' => qr/(?:mailboxfull|userunknown)/,
        '01005' => qr/filtered/,
        '01006' => qr/mailboxfull/,
        '01007' => qr/userunknown/,
        '01008' => qr/userunknown/,
    },
    'RU::Yandex' => {
        '01001' => qr/userunknown/,
        '01002' => qr/(?:userunknown|mailboxfull)/,
    },
    'UK::MessageLabs' => {
        '01001' => qr/userunknown/,
    },
    'US::AmazonSES' => {
        '01001' => qr/mailboxfull/,
        '01002' => qr/filtered/,
        '01003' => qr/userunknown/,
        '01004' => qr/mailboxfull/,
        '01005' => qr/blocked/,
        '01006' => qr/userunknown/,
        '01007' => qr/expired/,
        '01008' => qr/hostunknown/,
        '01009' => qr/userunknown/,
        '01010' => qr/userunknown/,
        '01011' => qr/userunknown/,
        '01012' => qr/userunknown/,
        '01013' => qr/userunknown/,
        '01014' => qr/filtered/,
    },
    'US::AmazonWorkMail' => {
        '01001' => qr/userunknown/,
        '01002' => qr/filtered/,
        '01003' => qr/systemerror/,
        '01004' => qr/mailboxfull/,
        '01005' => qr/expired/,
    },
    'US::Aol' => {
        '01001' => qr/hostunknown/,
        '01002' => qr/mailboxfull/,
        '01003' => qr/(?:mailboxfull|userunknown)/,
        '01004' => qr/(?:mailboxfull|userunknown)/,
        '01005' => qr/userunknown/,
        '01006' => qr/userunknown/,
        '01007' => qr/mailboxfull/,
        '01008' => qr/filtered/,
        '01009' => qr/blocked/,
        '01010' => qr/filtered/,
        '01011' => qr/filtered/,
        '01012' => qr/mailboxfull/,
        '01013' => qr/mailboxfull/,
        '01014' => qr/userunknown/,
    },
    'US::Bigfoot' => {
        '01001' => qr/spamdetected/,
    },
    'US::Facebook' => {
        '01001' => qr/filtered/,
    },
    'US::Google' => {
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
    },
    'US::Office365' => {
        '01001' => qr/filtered/,
        '01002' => qr/filtered/,
        '01003' => qr/filtered/,
        '01004' => qr/filtered/,
        '01005' => qr/filtered/,
        '01006' => qr/networkerror/,
    },
    'US::Outlook' => {
        '01002' => qr/userunknown/,
        '01003' => qr/userunknown/,
        '01007' => qr/blocked/,
        '01008' => qr/mailboxfull/,
        '01016' => qr/mailboxfull/,
        '01017' => qr/userunknown/,
        '01018' => qr/hostunknown/,
        '01019' => qr/(?:userunknown|mailboxfull)/,
        '01023' => qr/userunknown/,
        '01024' => qr/userunknown/,
        '01025' => qr/filtered/,
        '01026' => qr/filtered/,
    },
    'US::SendGrid' => {
        '01001' => qr/userunknown/,
        '01002' => qr/userunknown/,
        '01003' => qr/expired/,
        '01004' => qr/filtered/,
        '01005' => qr/userunknown/,
        '01006' => qr/mailboxfull/,
        '01007' => qr/userunknown/,
        '01008' => qr/filtered/,
        '01009' => qr/userunknown/,
    },
    'US::Verizon' => {
        '01001' => qr/userunknown/,
        '01002' => qr/userunknown/,
    },
    'US::Yahoo' => {
        '01001' => qr/userunknown/,
        '01002' => qr/mailboxfull/,
        '01003' => qr/filtered/,
        '01004' => qr/userunknown/,
    },
    'US::Zoho' => {
        '01001' => qr/userunknown/,
        '01002' => qr/(?:filtered|mailboxfull)/,
        '01003' => qr/filtered/,
        '01004' => qr/expired/,
    },
};

for my $x ( keys %$R ) {
    # Check each MTA module
    my $M = 'Sisimai::MSP::'.$x;
    my $d = './set-of-emails/private/'.lc($x); $d =~ s/::/-/;

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
                    ok length  $ee->deliverystatus,sprintf( "[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus );

                    is $ee->smtpagent, $x, sprintf( "[%s] %s/%s->smtpagent = %s", $n, $e, $x, $ee->smtpagent );

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

