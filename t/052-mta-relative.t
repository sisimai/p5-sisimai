use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $X = qr/\A(?:RFC3464|dovecot|mail[.]local|procmail|maildrop|vpopmail|vmailmgr)/;
my $R = {
    'RFC3464' => {
        '01' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/dovecot/ },
        '02' => { 'status' => qr/\A[45][.]0[.]\d+\z/, 'reason' => qr/(?:undefined|filtered|expired)/, 'agent' => qr/RFC3464/ },
        '03' => { 'status' => qr/\A[45][.]0[.]\d+\z/, 'reason' => qr/(?:undefined|expired)/, 'agent' => qr/RFC3464/ },
        '04' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
        '05' => { 'status' => qr/\A5[.]2[.]1\z/, 'reason' => qr/filtered/, 'agent' => qr/RFC3464/ },
        '06' => { 'status' => qr/\A5[.]5[.]0\z/, 'reason' => qr/userunknown/, 'agent' => qr/mail.local/ },
        '07' => { 'status' => qr/\A4[.]4[.]0\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
        '08' => { 'status' => qr/\A5[.]7[.]1\z/, 'reason' => qr/spamdetected/, 'agent' => qr/RFC3464/ },
        '09' => { 'status' => qr/\A4[.]3[.]0\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
        '10' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/, 'agent' => qr/RFC3464/ },
        '11' => { 'status' => qr/\A5[.]\d[.]\d+\z/, 'reason' => qr/spamdetected/, 'agent' => qr/RFC3464/ },
        '12' => { 'status' => qr/\A4[.]3[.]0\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
        '13' => { 'status' => qr/\A4[.]0[.]0\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
        '14' => { 'status' => qr/\A4[.]4[.]1\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
        '15' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mesgtoobig/, 'agent' => qr/RFC3464/ },
        '16' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/filtered/, 'agent' => qr/RFC3464/ },
        '17' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/expired/, 'agent' => qr/RFC3464/ },
        '18' => { 'status' => qr/\A5[.]1[.]1\z/, 'reason' => qr/userunknown/, 'agent' => qr/RFC3464/ },
        '19' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/, 'agent' => qr/RFC3464/ },
        '20' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailererror/, 'agent' => qr/RFC3464/ },
        '21' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/networkerror/, 'agent' => qr/RFC3464/ },
        '22' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/hostunknown/, 'agent' => qr/RFC3464/ },
        '23' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/mailboxfull/, 'agent' => qr/RFC3464/ },
        '24' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/, 'agent' => qr/RFC3464/ },
        '25' => { 'status' => qr/\A5[.]0[.]\d+\z/, 'reason' => qr/onhold/, 'agent' => qr/RFC3464/ },
    },
    'ARF' => {
        '01' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '02' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '03' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '04' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '05' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '06' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '07' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/auth-failure/ },
        '08' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/auth-failure/ },
        '09' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/auth-failure/ },
        '10' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '11' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '12' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/opt-out/ },
        '13' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/abuse/ },
        '14' => { 'status' => qr/\A\z/, 'reason' => qr/feedback/, 'feedbacktype' => qr/auth-failure/ },
    },
};

for my $x ( keys %$R ) {
    # Check each MTA module
    my $M = 'Sisimai::'.$x;
    my $v = undef;
    my $n = 0;
    my $c = 0;

    Module::Load::load( $M );
    use_ok $M;

    MAKE_TEST: {
        $v = $M->version;     ok $v, $x.'->version = '.$v;
        $v = $M->description; ok $v, $x.'->description = '.$v;

        $M->scan, undef, $M.'->scan = undef';

        PARSE_EACH_MAIL: for my $i ( 1 .. scalar keys %{ $R->{ $x } } ) {
            # Open email in eg/ directory
            my $emailfn = sprintf( "./eg/maildir-as-a-sample/new/%s-%02d.eml", lc($x), $i );
            my $mailbox = Sisimai::Mail->new( $emailfn );

            $n = sprintf( "%02d", $i );
            next unless defined $mailbox;
            ok -f $emailfn, sprintf( "[%s] %s/email = %s", $n, $M,$emailfn );

            while( my $r = $mailbox->read ) {
                # Parse each email in eg/ directory
                my $p = Sisimai::Message->new( 'data' => $r );
                my $o = undef;

                isa_ok $p, 'Sisimai::Message';
                isa_ok $p->ds, 'ARRAY';
                isa_ok $p->header, 'HASH';
                isa_ok $p->rfc822, 'HASH';
                ok length $p->from, sprintf( "[%s] %s->from = %s", $n, $M, $p->from );

                for my $e ( @{ $p->ds } ) {

                    for my $ee ( qw|recipient agent| ) {
                        # Length of each variable > 0
                        ok length $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }

                    for my $ee ( qw|
                        date spec reason status command action alias rhost lhost 
                        diagnosis feedbacktype softbounce| ) {
                        # Each key should be exist
                        ok exists $e->{ $ee }, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }

                    # Check the value of the following variables
                    if( $x eq 'ARF' ) {
                        # Check the value of "feedbacktype"
                        like $e->{'feedbacktype'}, $R->{'ARF'}->{ $n }->{'feedbacktype'}, 
                            sprintf( "[%s] %s->feedbacktype = %s", $n, $x, $e->{'feedbacktype'} );
                    }

                    unless( $x =~ m/\AmFILTER\z/ ) {
                        # mFILTER => m-FILTER
                        if( $x eq 'RFC3464' ) {
                            # X4 is qmail clone
                            like $e->{'agent'}, $X, sprintf( "[%s] %s->agent = %s", $n, $x, $e->{'agent'} );

                        } else {
                            # Other MTA modules
                            ok $e->{'agent'}, sprintf( "[%s] %s->agent = %s", $n, $x, $e->{'agent'} );
                        }
                    }
                    like $e->{'recipient'}, qr/[0-9A-Za-z@-_.]+/, sprintf( "[%s] %s->recipient = %s", $n, $x, $e->{'recipient'} );

                    for my $ee ( 'rhost', 'lhost' ) {
                        # Check rhost and lhost are valid hostname or not
                        next unless $e->{ $ee };
                        next if $x =~ m/\A(?:qmail|Exim|Exchange|X4)\z/;
                        like $e->{ $ee }, qr/\A(?:localhost|.+[.].+)\z/, sprintf( "[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee } );
                    }
                }


                $o = Sisimai::Data->make( 'data' => $p );
                isa_ok $o, 'ARRAY';
                ok scalar @$o, sprintf( "%s/entry = %s", $M, scalar @$o );

                for my $e ( @$o ) {
                    # Check each accessor
                    isa_ok $e, 'Sisimai::Data';
                    ok defined $e->replycode, sprintf( "[%s] %s->replycode = %s", $n, $x, $e->replycode );
                    if( length $e->replycode ) {
                        # Check SMTP Reply Code format
                        like $e->replycode, qr/\A[45]\d\d\z/, sprintf( "[%s] %s->replycode = %s", $n, $x, $e->replycode );
                    }

                    like $e->deliverystatus, $R->{ $x }->{ $n }->{'status'}, sprintf( "[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus );
                    like $e->reason,         $R->{ $x }->{ $n }->{'reason'}, sprintf( "[%s] %s->reason = %s", $n, $x, $e->reason );

                    unlike $e->lhost,     qr/[ ]/, sprintf( "[%s] %s->lhost = %s", $n, $x, $e->lhost );
                    unlike $e->rhost,     qr/[ ]/, sprintf( "[%s] %s->rhost = %s", $n, $x, $e->rhost );
                    unlike $e->alias,     qr/[ ]/, sprintf( "[%s] %s->alias = %s", $n, $x, $e->alias );
                    unlike $e->listid,    qr/[ ]/, sprintf( "[%s] %s->listid = %s", $n, $x, $e->listid );
                    unlike $e->messageid, qr/[ ]/, sprintf( "[%s] %s->messageid = %s", $n, $x, $e->messageid );
                }
                $c++;
            }
        }
        ok $c, $M.'/the number of emails = '.$c;
    }
}


done_testing;
