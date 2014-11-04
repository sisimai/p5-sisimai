use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail;

my $PackageName = 'Sisimai::Mail';
my $MethodNames = {
    'class' => [ 'new' ],
    'object' => [ 'data', 'mbox', 'mail', 'read' ],
};
my $SampleEmail = {
    'mailbox' => './eg/mbox-as-a-sample',
    'maildir' => './eg/maildir-as-a-sample/cur',
};
my $IsNotBounce = {
    'maildir' => './eg/maildir-as-a-sample/tmp',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    MAILBOX: {
        my $mailbox = $PackageName->new( $SampleEmail->{'mailbox'} );
        my $emindex = 0;

        isa_ok $mailbox, $PackageName;
        can_ok $mailbox, @{ $MethodNames->{'object'} };
        is $mailbox->data, $SampleEmail->{'mailbox'}, '->data = '.$mailbox->data;
        is $mailbox->mbox, 1, '->mbox = 1';
        isa_ok $mailbox->mail, $PackageName.'::Mbox';

        while( my $r = $mailbox->read ) {
            ok length $r, 'mailbox->read('.( $emindex + 1 ).')';
            $emindex++;
        }
        is $emindex, 37;
    }

    MAILDIR: {
        my $maildir = $PackageName->new( $SampleEmail->{'maildir'} );
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
        is $maildir->data, $SampleEmail->{'maildir'}, '->data = '.$maildir->data;
        is $maildir->mbox, 0, '->mbox = 0';
        isa_ok $maildir->mail, $PackageName.'::Maildir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.( $emindex + 1 ).')';
            $emindex++;
        }
        is $emindex, 37;
    }

    NOTBOUNCE: {
        my $maildir = $PackageName->new( $IsNotBounce->{'maildir'} );
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
        is $maildir->data, $IsNotBounce->{'maildir'}, '->data = '.$maildir->data;
        is $maildir->mbox, 0, '->mbox = 0';
        isa_ok $maildir->mail, $PackageName.'::Maildir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.( $emindex + 1 ).')';
            $emindex++;
        }
        is $emindex, 1;
    }
}

done_testing;
