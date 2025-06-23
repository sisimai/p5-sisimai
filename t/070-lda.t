use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::LDA;

my $Package = 'Sisimai::LDA';
my $Methods = { 'class'  => ['find'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    use Sisimai::Mail;
    use Sisimai::Message;

    my $EmailFiles = {
        "rfc3464-01"       => "mailboxfull",
        "rfc3464-04"       => "systemerror",
        "rfc3464-06"       => "userunknown",
        "lhost-postfix-01" => "mailererror",
        "lhost-qmail-10"   => "suspend",
    };
    for my $e ( keys %$EmailFiles ) {
        my $mailbox = Sisimai::Mail->new(sprintf("./set-of-emails/maildir/bsd/%s.eml", $e));
        my $counter = 0;

        while( my $r = $mailbox->data->read ) {
            my $message = Sisimai::Message->rise({ 'data' => $r });
            $counter++;
            isa_ok $message, "HASH";
            isa_ok $message->{"ds"}, "ARRAY";

            for my $f ( $message->{'ds'}->@* ) {
                my $factobj = {
                    "diagnosticcode" => $f->{'diagnosis'} || "",
                    "command"        => $f->{'command'}   || "",
                };
                my $v = Sisimai::LDA->find($factobj);
                is $v, $EmailFiles->{ $e }, sprintf("%s [%02d] Sisimai::LDA->find() = %s", $e, $counter, $v);
            }
        }
    }
    is $Package->find(undef), "";
}

done_testing;
