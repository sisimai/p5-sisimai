use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail;
use Sisimai::SMTP::Transcript;

my $Package = 'Sisimai::SMTP::Transcript';
my $Methods = { 'class' => ['rise'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $targetmail = 'set-of-emails/maildir/bsd/lhost-postfix-75.eml';
    my $mailobject = Sisimai::Mail->new($targetmail);
    my $entiremesg = $mailobject->read; $entiremesg =~ s/\A.+?\n\n(.+)\z/$1/ms;
    my $transcript = Sisimai::SMTP::Transcript->rise($entiremesg, 'In:', 'Out:');
    my $resmtpcomm = qr/(?:CONN|HELO|EHLO|AUTH|MAIL|RCPT|DATA|QUIT|RSET|X[A-Z]+)/;

    is $Package->rise([]), undef;
    isa_ok $transcript, 'ARRAY';
    ok scalar @$transcript;

    for my $e ( @$transcript ) {
        my $v = $e->{'command'};
        like $v, $resmtpcomm, sprintf("[%s] command = %s", $v, $e->{'command'});

        ok defined $e->{'argument'}, sprintf("[%s] argument = %s", $v, $e->{'argument'});
        if( $e->{'command'} =~ /\A(?:MAIL|RCPT)/ ) {
            like $e->{'argument'}, qr/\A.+[@].+\z/, sprintf("[%s] email address = %s", $v, $e->{'argument'});

        } elsif( $e->{'command'} =~ /\A(?:DATA|QUIT|RSET)/ ) {
            is $e->{'argument'}, '', sprintf("[%s] the argument should be empty", $v);
        }

        my $r = $e->{'response'};
        ok defined $r, sprintf("[%s] response", $v);
        isa_ok $r, 'HASH';
        like $r->{'reply'}, qr/\A[2345]\d\d/, sprintf("[%s] response->reply = %s", $v, $r->{'reply'});
        ok defined $r->{'status'}, sprintf("[%s] response->status = %s", $v, $r->{'status'});
        like $r->{'status'}, qr/\A[245][.]\d{1,3}[.]\d{1,3}/ if $r->{'status'};
        isa_ok $r->{'text'}, 'ARRAY';
        ok scalar @{ $r->{'text'} }, sprintf("[%s] response->text have %d elements", $v, scalar @{ $r->{'text'} });
        for my $f ( @{ $r->{'text'} } ) {
            like $f, qr/\A[2345]\d\d[ -]/, sprintf("[%s] response->text = %s", $v, $f);
        }

        my $p = $e->{'parameter'};
        isa_ok $e->{'parameter'}, 'HASH';
        next unless scalar keys %$p;

        for my $g ( keys %$p ) {
            ok length $g, sprintf("[%s] parameter->%s has a value", $v, $g);
            ok length $p->{ $g }, sprintf("[%s] parameter->%s = %s", $v, $g, $p->{ $g });
        }
    }

    my $q = 'nekochan-nyaan';
    is(Sisimai::SMTP::Transcript->rise(undef), undef);
    is(Sisimai::SMTP::Transcript->rise(''), undef);
    is(Sisimai::SMTP::Transcript->rise($q, ''), undef);
    is(Sisimai::SMTP::Transcript->rise($q, '', ''), undef);
    is(Sisimai::SMTP::Transcript->rise($q, 'x', 'y'), undef);
}

done_testing;

