use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Mail;
use Sisimai::Message;
use Module::Load;

my $MDAPatterns = qr/\A(?:RFC3464|dovecot|mail[.]local|procmail|maildrop|vpopmail|vmailmgr)/;
my $MTARelative = {
    'RFC3464' => {
        '01' => { 's' => qr/\A5[.]1[.]1\z/,     'r' => qr/mailboxfull/, 'a' => qr/dovecot/, 'b' => qr/\A1\z/ },
        '02' => { 's' => qr/\A[45][.]0[.]\d+\z/,'r' => qr/(?:undefined|filtered|expired)/, 'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
        '03' => { 's' => qr/\A[45][.]0[.]\d+\z/,'r' => qr/(?:undefined|expired)/,          'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
        '04' => { 's' => qr/\A5[.]5[.]0\z/,     'r' => qr/mailererror/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '05' => { 's' => qr/\A5[.]2[.]1\z/,     'r' => qr/filtered/,    'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '06' => { 's' => qr/\A5[.]5[.]0\z/,     'r' => qr/userunknown/, 'a' => qr/mail.local/, 'b' => qr/\A0\z/ },
        '07' => { 's' => qr/\A4[.]4[.]0\z/,     'r' => qr/expired/,     'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '08' => { 's' => qr/\A5[.]7[.]1\z/,     'r' => qr/spamdetected/,'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '09' => { 's' => qr/\A4[.]3[.]0\z/,     'r' => qr/mailboxfull/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '10' => { 's' => qr/\A5[.]1[.]1\z/,     'r' => qr/userunknown/, 'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
        '11' => { 's' => qr/\A5[.]\d[.]\d+\z/,  'r' => qr/spamdetected/,'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '12' => { 's' => qr/\A4[.]3[.]0\z/,     'r' => qr/mailboxfull/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '13' => { 's' => qr/\A4[.]0[.]0\z/,     'r' => qr/mailererror/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '14' => { 's' => qr/\A4[.]4[.]1\z/,     'r' => qr/expired/,     'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '15' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/mesgtoobig/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '16' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/filtered/,    'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '17' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/expired/,     'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '18' => { 's' => qr/\A5[.]1[.]1\z/,     'r' => qr/userunknown/, 'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
        '19' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/onhold/,      'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
        '20' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/mailererror/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '21' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/networkerror/,'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '22' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/hostunknown/, 'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
        '23' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/mailboxfull/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '24' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/onhold/,      'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
        '25' => { 's' => qr/\A5[.]0[.]\d+\z/,   'r' => qr/onhold/,      'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
        '26' => { 's' => qr/\A5[.]1[.]1\z/,     'r' => qr/userunknown/, 'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
        '27' => { 's' => qr/\A4[.]4[.]6\z/,     'r' => qr/networkerror/,'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
        '28' => { 's' => qr/\A2[.]1[.]5\z/,     'r' => qr/delivered/,   'a' => qr/RFC3464/, 'b' => qr/\A-1\z/ },
        '29' => { 's' => qr/\A5[.]5[.]0\z/,     'r' => qr/syntaxerror/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    },
    'RFC3834' => {
        '01' => { 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
        '02' => { 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
        '03' => { 's' => qr/\A\z/, 'r' => qr/vacation/, 'b' => qr/\A-1\z/ },
    },
    'ARF' => {
        '01' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '02' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '03' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '04' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '05' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '06' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/, 'b' => qr/\A-1\z/ },
        '07' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
        '08' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
        '09' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
        '10' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,    'b' => qr/\A-1\z/ },
        '11' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,    'b' => qr/\A-1\z/ },
        '12' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/opt-out/,  'b' => qr/\A-1\z/ },
        '13' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,    'b' => qr/\A-1\z/ },
        '14' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/auth-failure/, 'b' => qr/\A-1\z/ },
        '15' => { 's' => qr/\A\z/, 'r' => qr/feedback/, 'f' => qr/abuse/,    'b' => qr/\A-1\z/ },
    },
};

for my $x ( keys %$MTARelative ) {
    # Check each MTA module
    my $M = 'Sisimai::'.$x;
    my $v = undef;
    my $n = 0;
    my $c = 0;

    Module::Load::load($M);
    use_ok $M;

    MAKE_TEST: {
        $v = $M->description; ok $v, $x.'->description = '.$v;
        $v = $M->pattern;     ok keys %$v; isa_ok $v, 'HASH';

        $M->scan, undef, $M.'->scan = undef';

        PARSE_EACH_MAIL: for my $i ( 1 .. scalar keys %{ $MTARelative->{ $x } } ) {
            # Open email in set-of-emails/ directory
            my $emailfn = sprintf("./set-of-emails/maildir/bsd/%s-%02d.eml", lc($x), $i);
            my $mailbox = Sisimai::Mail->new($emailfn);

            $n = sprintf("%02d", $i);
            next unless defined $mailbox;
            ok -f $emailfn, sprintf("[%s] %s/email = %s", $n, $M,$emailfn);

            while( my $r = $mailbox->read ) {
                # Parse each email in set-of-emails/maidir/bsd directory
                my $p = Sisimai::Message->new('data' => $r);
                my $o = undef;

                isa_ok $p, 'Sisimai::Message';
                isa_ok $p->ds, 'ARRAY';
                isa_ok $p->header, 'HASH';
                isa_ok $p->rfc822, 'HASH';
                ok length $p->from, sprintf("[%s] %s->from = %s", $n, $M, $p->from);

                for my $e ( @{ $p->ds } ) {

                    for my $ee ( qw|recipient agent| ) {
                        # Length of each variable > 0
                        ok length $e->{ $ee }, sprintf("[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee });
                    }

                    for my $ee ( qw|
                        date spec reason status command action alias rhost lhost 
                        diagnosis feedbacktype softbounce| ) {
                        # Each key should be exist
                        ok exists $e->{ $ee }, sprintf("[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee });
                    }

                    # Check the value of the following variables
                    if( $x eq 'ARF' ) {
                        # Check the value of "feedbacktype"
                        like $e->{'feedbacktype'}, $MTARelative->{'ARF'}->{ $n }->{'f'}, 
                            sprintf("[%s] %s->feedbacktype = %s", $n, $x, $e->{'feedbacktype'});
                    }

                    unless( $x eq 'mFILTER' ) {
                        # mFILTER => m-FILTER
                        if( $x eq 'RFC3464' ) {
                            # X4 is qmail clone
                            like $e->{'agent'}, $MDAPatterns, sprintf("[%s] %s->agent = %s", $n, $x, $e->{'agent'});

                        } else {
                            # Other MTA modules
                            ok $e->{'agent'}, sprintf("[%s] %s->agent = %s", $n, $x, $e->{'agent'});
                        }
                    }

                    like   $e->{'recipient'}, qr/[0-9A-Za-z@-_.]+/, sprintf("[%s] %s->recipient = %s", $n, $x, $e->{'recipient'});
                    unlike $e->{'recipient'}, qr/[ ]/,              sprintf("[%s] %s->recipient = %s", $n, $x, $e->{'recipient'});
                    unlike $e->{'command'},   qr/[ ]/,              sprintf("[%s] %s->command = %s", $n, $x, $e->{'command'});

                    if( length $e->{'status'} ) {
                        # Check the value of "status"
                        like $e->{'status'}, qr/\A(?:[245][.]\d[.]\d+)\z/,
                            sprintf("[%s] %s->status = %s", $n, $x, $e->{'status'});
                    }

                    if( length $e->{'action'} ) {
                        # Check the value of "action"
                        like $e->{'action'}, qr/\A(?:fail.+|delayed|expired|delivered|deliverable)\z/, 
                            sprintf("[%s] %s->action = %s", $n, $x, $e->{'action'});
                    }

                    for my $ee ( 'rhost', 'lhost' ) {
                        # Check rhost and lhost are valid hostname or not
                        next unless $e->{ $ee };
                        next if $x =~ m/\A(?:qmail|Exim|Exchange|X4)/;
                        like $e->{ $ee }, qr/\A(?:localhost|.+[.].+)\z/, sprintf("[%s] %s->%s = %s", $n, $x, $ee, $e->{ $ee });
                    }
                }


                $o = Sisimai::Data->make('data' => $p, 'delivered' => 1);
                isa_ok $o, 'ARRAY';
                ok scalar @$o, sprintf("%s/entry = %s", $M, scalar @$o);

                for my $e ( @$o ) {
                    # Check each accessor
                    isa_ok $e,            'Sisimai::Data';
                    isa_ok $e->timestamp, 'Sisimai::Time';
                    isa_ok $e->addresser, 'Sisimai::Address';
                    isa_ok $e->recipient, 'Sisimai::Address';

                    ok defined $e->replycode,      sprintf("[%s] %s->replycode = %s", $n, $x, $e->replycode);
                    ok defined $e->subject,        sprintf("[%s] %s->subject = ...", $n, $x);
                    ok defined $e->smtpcommand,    sprintf("[%s] %s->smtpcommand = %s", $n, $x, $e->smtpcommand);
                    ok defined $e->diagnosticcode, sprintf("[%s] %s->diagnosticcode = %s", $n, $x, $e->diagnosticcode);
                    ok defined $e->diagnostictype, sprintf("[%s] %s->diagnostictype = %s", $n, $x, $e->diagnostictype);

                    if( $x eq 'ARF' || $x eq 'RFC3834' ) {
                        ok defined $e->deliverystatus, sprintf("[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus);
                    } else {
                        ok length  $e->deliverystatus, sprintf("[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus);
                    }

                    ok length  $e->token,          sprintf("[%s] %s->token = %s", $n, $x, $e->token);
                    ok length  $e->smtpagent,      sprintf("[%s] %s->smtpagent = %s", $n, $x, $e->smtpagent);
                    ok length  $e->timezoneoffset, sprintf("[%s] %s->timezoneoffset = %s", $n, $x, $e->timezoneoffset);

                    is $e->addresser->host, $e->senderdomain, sprintf("[%s] %s->senderdomain = %s", $n, $x, $e->senderdomain);
                    is $e->recipient->host, $e->destination,  sprintf("[%s] %s->destination = %s", $n, $x, $e->destination);

                    like $e->replycode,      qr/\A(?:[245]\d\d|)\z/,         sprintf("[%s] %s->replycode = %s", $n, $x, $e->replycode);
                    like $e->timezoneoffset, qr/\A[-+]\d{4}\z/,              sprintf("[%s] %s->timezoneoffset = %s", $n, $x, $e->timezoneoffset);
                    like $e->deliverystatus, $MTARelative->{$x}->{$n}->{'s'},sprintf("[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus);
                    like $e->reason,         $MTARelative->{$x}->{$n}->{'r'},sprintf("[%s] %s->reason = %s", $n, $x, $e->reason);
                    like $e->softbounce,     $MTARelative->{$x}->{$n}->{'b'},sprintf("[%s] %s->softbounce = %s", $n, $x, $e->softbounce);
                    like $e->token,          qr/\A([0-9a-f]{40})\z/,         sprintf("[%s] %s->token = %s", $n, $x, $e->token);

                    if( $x eq 'ARF' ) {
                        # Check the value of "feedbacktype"
                        like $e->feedbacktype, $MTARelative->{'ARF'}->{ $n }->{'f'}, 
                            sprintf("[%s] %s->feedbacktype = %s", $n, $x, $e->feedbacktype);
                    }

                    unlike $e->deliverystatus,qr/[ \r]/, sprintf("[%s] %s->deliverystatus = %s", $n, $x, $e->deliverystatus);
                    unlike $e->diagnostictype,qr/[ \r]/, sprintf("[%s] %s->diagnostictype = %s", $n, $x, $e->diagnostictype);
                    unlike $e->smtpcommand,   qr/[ \r]/, sprintf("[%s] %s->smtpcommand = %s", $n, $x, $e->smtpcommand);

                    unlike $e->lhost,     qr/[ \r]/, sprintf("[%s] %s->lhost = %s", $n, $x, $e->lhost);
                    unlike $e->rhost,     qr/[ \r]/, sprintf("[%s] %s->rhost = %s", $n, $x, $e->rhost);
                    unlike $e->alias,     qr/[ \r]/, sprintf("[%s] %s->alias = %s", $n, $x, $e->alias);
                    unlike $e->listid,    qr/[ \r]/, sprintf("[%s] %s->listid = %s", $n, $x, $e->listid);
                    unlike $e->action,    qr/[ \r]/, sprintf("[%s] %s->action = %s", $n, $x, $e->action);
                    unlike $e->messageid, qr/[ \r]/, sprintf("[%s] %s->messageid = %s", $n, $x, $e->messageid);

                    unlike $e->addresser->user, qr/[ \r]/, sprintf("[%s] %s->addresser->user = %s", $n, $x, $e->addresser->user);
                    unlike $e->addresser->host, qr/[ \r]/, sprintf("[%s] %s->addresser->host = %s", $n, $x, $e->addresser->host);
                    unlike $e->addresser->verp, qr/[ \r]/, sprintf("[%s] %s->addresser->verp = %s", $n, $x, $e->addresser->verp);
                    unlike $e->addresser->alias,qr/[ \r]/, sprintf("[%s] %s->addresser->alias = %s", $n, $x, $e->addresser->alias);

                    unlike $e->recipient->user, qr/[ \r]/, sprintf("[%s] %s->recipient->user = %s", $n, $x, $e->recipient->user);
                    unlike $e->recipient->host, qr/[ \r]/, sprintf("[%s] %s->recipient->host = %s", $n, $x, $e->recipient->host);
                    unlike $e->recipient->verp, qr/[ \r]/, sprintf("[%s] %s->recipient->verp = %s", $n, $x, $e->recipient->verp);
                    unlike $e->recipient->alias,qr/[ \r]/, sprintf("[%s] %s->recipient->alias = %s", $n, $x, $e->recipient->alias);
                }
                $c++;
            }
        }
        ok $c, $M.'/the number of emails = '.$c;
    }
}


done_testing;
