use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MDA;

my $PackageName = 'Sisimai::MDA';
my $MethodNames = {
    'class' => [ 'scan' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    use Sisimai::Mail;
    use Sisimai::Message;

    my $ErrorMesgs = [
        'Your message to neko was automatically rejected:'."\n".'Not enough disk space',
        'mail.local: Disc quota exceeded',
        'procmail: Quota exceeded while writing',
        'maildrop: maildir over quota.',
        'vdelivermail: user is over quota',
        'vdeliver: Delivery failed due to system quota violation',
    ];

    my $emailfn = './eg/maildir-as-a-sample/new/rfc3464-01.eml';
    my $mailbox = Sisimai::Mail->new( $emailfn );
    my $message = undef;
    my $headers = {};

    while( my $r = $mailbox->read ) {
        $message = Sisimai::Message->new( 'data' => $r );
        $headers->{'from'} = $message->from;

        for my $e ( @$ErrorMesgs ) {
            my $v = Sisimai::MDA->scan( $headers, \$e );

            isa_ok $v, 'HASH';
            ok $v->{'mda'}, 'mda => '.$v->{'mda'};
            is $v->{'reason'}, 'mailboxfull', 'reason => '.$v->{'reason'};
            ok $v->{'message'}, 'message => '.$v->{'message'};
        }
    }


}

done_testing;
