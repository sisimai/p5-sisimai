use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Data;
use Sisimai::Message;
use Module::Load;
use IO::File;
use JSON;

my $R = {
    'US::SendGrid' => {
        '01001' => qr/(?:userunknown|filtered|mailboxfull)/,
        '01002' => qr/(?:mailboxfull|filtered)/,
        '01003' => qr/userunknown/,
        '01004' => qr/filtered/,
        '01005' => qr/filtered/,
        '01006' => qr/userunknown/,
        '01007' => qr/filtered/,
        '01008' => qr/userunknown/,
        '01009' => qr/userunknown/,
        '01010' => qr/userunknown/,
        '01011' => qr/hostunknown/,
    },
};

for my $x ( keys %$R ) {
    # Check each MTA module
    my $M = 'Sisimai::CED::'.$x;
    my $d = './set-of-emails/private/ced-'.lc($x); $d =~ s/::/-/;

    Module::Load::load($M);
    use_ok $M;

    if( -d $d ) {

        my $h = undef;
        my $n = 0;
        my $j = JSON->new;
        ok $d, sprintf("%s %s", $x, $d);

        opendir($h, $d);
        while( my $e = readdir $h ) {
            # Open email in set-of-emails/private directory
            next if $e eq '.';
            next if $e eq '..';
            next unless $e =~ m/[.]json\z/;

            my $jsonset = sprintf("%s/%s", $d, $e); next unless -f $jsonset;
            my $fhandle = IO::File->new($jsonset, 'r');
            my $jsonobj = $j->decode(<$fhandle>);
            my $bounces = [];

            $n = $e; $n =~ s/\A(\d+)[-].*[.]json/$1/;
            push @$bounces, (ref $jsonobj eq 'ARRAY' ) ? @$jsonobj : $jsonobj;
            $fhandle->close;

            while( my $r = shift @$bounces ) {
                # Parse each JSON file in set-of-emails/ directory
                ok length $r;

                my $p = Sisimai::Message->new('data' => $r, 'input' => 'json');
                my $v = Sisimai::Data->make('data' => $p, 'input' => 'json');
                my $y = undef;

                next unless $p;
                is ref($p), 'Sisimai::Message', sprintf("[%s] %s/%s(Sisimai::Message)", $n, $e, $x);
                is ref($v), 'ARRAY', sprintf("[%s] %s/%s(ARRAY)", $n, $e, $x);
                # ok scalar @$v, sprintf("[%s] %s/%s(%d)", $n, $e, $x, scalar @$v);

                for my $ee ( @$v ) {
                    isa_ok $ee, 'Sisimai::Data';

                    ok length  $ee->token, sprintf("[%s] %s/%s->token = %s", $n, $e, $x, $ee->token);
                    ok defined $ee->lhost, sprintf("[%s] %s/%s->lhost = %s", $n, $e, $x, $ee->lhost);
                    ok defined $ee->rhost, sprintf("[%s] %s/%s->rhost = %s", $n, $e, $x, $ee->rhost);
                    ok defined $ee->alias, sprintf("[%s] %s/%s->alias = %s", $n, $e, $x, $ee->alias);
                    ok defined $ee->listid,sprintf("[%s] %s/%s->listid = %s",$n, $e, $x, $ee->listid);
                    ok defined $ee->action,sprintf("[%s] %s/%s->action = %s",$n, $e, $x, $ee->action);

                    ok defined $ee->messageid,     sprintf("[%s] %s/%s->messageid = %s", $n, $e, $x, $ee->messageid);
                    ok defined $ee->smtpcommand,   sprintf("[%s] %s/%s->smtpcommand = %s", $n, $e, $x, $ee->smtpcommand);
                    ok defined $ee->diagnosticcode,sprintf("[%s] %s/%s->diagnosticcode = %s", $n, $e, $x, $ee->diagnosticcode);
                    ok defined $ee->diagnostictype,sprintf("[%s] %s/%s->diagnostictype = %s", $n, $e, $x, $ee->diagnostictype);
                    ok defined $ee->replycode,     sprintf("[%s] %s/%s->replycode = %s", $n, $e, $x, $ee->replycode);
                    ok defined $ee->feedbacktype,  sprintf("[%s] %s/%s->feedbacktype = %s", $n, $e, $x, $ee->feedbacktype);
                    ok defined $ee->subject,       sprintf("[%s] %s/%s->subject", $n, $e, $x);
                    ok defined $ee->deliverystatus,sprintf("[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus);

                    is $ee->smtpagent, 'CED::'.$x, sprintf("[%s] %s/%s->smtpagent = %s", $n, $e, $x, $ee->smtpagent);

                    if( length $ee->action ) {
                        # Check the value of action
                        like $ee->action, qr/(?:fail.+|delayed|expired)\z/, 
                            sprintf("[%s] %s/%s->action = %s", $n, $e, $x, $ee->action);
                    }

                    if( length $ee->deliverystatus ) {
                        # Check the value of D.S.N. format
                        like $ee->deliverystatus, qr/\A[45][.]\d/, 
                            sprintf("[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus);
                    }

                    if( $ee->reason =~ m/(?:feedback|vacation|delivered)/ ) {
                        # The value of "softbounce" is -1 when a reason is feedback or vacation or delivered.
                        is $ee->softbounce, -1, sprintf("[%s] %s/%s->softbounce = %d", $n, $e, $x, $ee->softbounce);

                    } elsif( $ee->reason =~ m/(?:unknown|hasmoved)/ ) {
                        # The value of "softbounce" is 0 when a reason is userunknown or hostunknown or hasmoved.
                        is $ee->softbounce, 0, sprintf("[%s] %s/%s->softbounce = %d", $n, $e, $x, $ee->softbounce);

                    } else {
                        like $ee->softbounce, qr/[01]\z/, sprintf("[%s] %s/%s->softbounce = %d", $n, $e, $x, $ee->softbounce);
                    }

                    like $ee->reason,         $R->{ $x }->{ $n },   sprintf("[%s] %s/%s->reason = %s", $n, $e, $x, $ee->reason);
                    like $ee->replycode,      qr/\A(?:[45]\d\d|)\z/,sprintf("[%s] %s/%s->replycode = %s", $n, $e, $x, $ee->replycode);
                    like $ee->timezoneoffset, qr/\A[+-]\d+\z/,      sprintf("[%s] %s/%s->timezoneoffset = %s", $n, $e, $x, $ee->timezoneoffset);

                    unlike $ee->deliverystatus,qr/[ ]/, sprintf("[%s] %s/%s->deliverystatus = %s", $n, $e, $x, $ee->deliverystatus);
                    unlike $ee->smtpcommand,   qr/[ ]/, sprintf("[%s] %s/%s->smtpcommand = %s", $n, $e, $x, $ee->smtpcommand);

                    unlike $ee->lhost,     qr/[ ]/, sprintf("[%s] %s/%s->lhost = %s", $n, $e, $x, $ee->lhost);
                    unlike $ee->rhost,     qr/[ ]/, sprintf("[%s] %s/%s->rhost = %s", $n, $e, $x, $ee->rhost);
                    unlike $ee->alias,     qr/[ ]/, sprintf("[%s] %s/%s->alias = %s", $n, $e, $x, $ee->alias);
                    unlike $ee->listid,    qr/[ ]/, sprintf("[%s] %s/%s->listid = %s", $n, $e, $x, $ee->listid);
                    unlike $ee->action,    qr/[ ]/, sprintf("[%s] %s/%s->action = %s", $n, $e, $x, $ee->action);
                    unlike $ee->messageid, qr/[ ]/, sprintf("[%s] %s/%s->messageid = %s", $n, $e, $x, $ee->messageid);

                    isa_ok $ee->timestamp, 'Sisimai::Time'; $y = $ee->timestamp;
                    like $y->year, qr/\A\d{4}\z/,sprintf("[%s] %s/%s->timestamp->year = %s", $n, $e, $x, $y->year);
                    like $y->month,qr/\A\w+\z/,  sprintf("[%s] %s/%s->timestamp->month = %s", $n, $e, $x, $y->month);
                    like $y->mday, qr/\A\d+\z/,  sprintf("[%s] %s/%s->timestamp->mday = %s", $n, $e, $x, $y->mday);
                    like $y->day,  qr/\A\w+\z/,  sprintf("[%s] %s/%s->timestamp->day = %s", $n, $e, $x, $y->day);

                    isa_ok $ee->addresser, 'Sisimai::Address'; $y = $ee->addresser;
                    ok length  $y->host,            sprintf("[%s] %s/%s->addresser->host = %s", $n, $e, $x, $y->host);
                    ok length  $y->user,            sprintf("[%s] %s/%s->addresser->user = %s", $n, $e, $x, $y->user);
                    ok length  $y->address,         sprintf("[%s] %s/%s->addresser->address = %s", $n, $e, $x, $y->address);
                    ok defined $y->verp,            sprintf("[%s] %s/%s->addresser->verp = %s", $n, $e, $x, $y->verp);
                    ok defined $y->alias,           sprintf("[%s] %s/%s->addresser->alias = %s", $n, $e, $x, $y->alias);

                    is $y->host, $ee->senderdomain, sprintf("[%s] %s/%s->senderdomain = %s", $n, $e, $x, $y->host);
                    unlike $y->host,   qr/[ ]/,     sprintf("[%s] %s/%s->addresser->host = %s", $n, $e, $x, $y->host);
                    unlike $y->user,   qr/[ ]/,     sprintf("[%s] %s/%s->addresser->user = %s", $n, $e, $x, $y->user);
                    unlike $y->verp,   qr/[ ]/,     sprintf("[%s] %s/%s->addresser->verp = %s", $n, $e, $x, $y->verp);
                    unlike $y->alias,  qr/[ ]/,     sprintf("[%s] %s/%s->addresser->alias = %s", $n, $e, $x, $y->alias);
                    unlike $y->address,qr/[ ]/,     sprintf("[%s] %s/%s->addresser->address = %s", $n, $e, $x, $y->address);

                    isa_ok $ee->recipient, 'Sisimai::Address'; $y = $ee->recipient;
                    ok length  $y->host,            sprintf("[%s] %s/%s->recipient->host = %s", $n, $e, $x, $y->host);
                    ok length  $y->user,            sprintf("[%s] %s/%s->recipient->user = %s", $n, $e, $x, $y->user);
                    ok length  $y->address,         sprintf("[%s] %s/%s->recipient->address = %s", $n, $e, $x, $y->address);
                    ok defined $y->verp,            sprintf("[%s] %s/%s->recipient->verp = %s", $n, $e, $x, $y->verp);
                    ok defined $y->alias,           sprintf("[%s] %s/%s->recipient->alias = %s", $n, $e, $x, $y->alias);

                    is $y->host, $ee->destination,  sprintf("[%s] %s/%s->destination = %s", $n, $e, $x, $y->host);
                    unlike $y->host,   qr/[ ]/,     sprintf("[%s] %s/%s->recipient->host = %s", $n, $e, $x, $y->host);
                    unlike $y->user,   qr/[ ]/,     sprintf("[%s] %s/%s->recipient->user = %s", $n, $e, $x, $y->user);
                    unlike $y->verp,   qr/[ ]/,     sprintf("[%s] %s/%s->recipient->verp = %s", $n, $e, $x, $y->verp);
                    unlike $y->alias,  qr/[ ]/,     sprintf("[%s] %s/%s->recipient->alias = %s", $n, $e, $x, $y->alias);
                    unlike $y->address,qr/[ ]/,     sprintf("[%s] %s/%s->recipient->address = %s", $n, $e, $x, $y->address);
                }
            }
        }
        close $h;
    }
}
done_testing;

