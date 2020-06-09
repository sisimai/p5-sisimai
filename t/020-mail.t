use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail;

my $PackageName = 'Sisimai::Mail';
my $MethodNames = {
    'class' => ['new'],
    'object' => ['path', 'kind', 'data', 'type', 'mail', 'hook', 'close'],
};
my $SampleEmail = {
    'mailbox' => './set-of-emails/mailbox/mbox-0',
    'maildir' => './set-of-emails/maildir/err',
};
my $IsNotBounce = {
    'maildir' => './set-of-emails/maildir/not',
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    MAILBOX: {
        my $mailbox = $PackageName->new($SampleEmail->{'mailbox'});
        my $emindex = 0;

        isa_ok $mailbox, $PackageName;
        can_ok $mailbox, @{ $MethodNames->{'object'} };
        is $mailbox->path, $SampleEmail->{'mailbox'}, '->path = '.$mailbox->path;
        is $mailbox->kind, 'mailbox', '->kind = mailbox';
        isa_ok $mailbox->data, $PackageName.'::Mbox';

        while( my $r = $mailbox->data->read ) {
            ok length $r, 'mailbox->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 37;

        # old methods
        isa_ok $mailbox->mail, $PackageName.'::Mbox';
        is $mailbox->type, 'mailbox', '->type = mailbox';
        ok $mailbox->close;
    }

    MAILDIR: {
        my $maildir = $PackageName->new($SampleEmail->{'maildir'});
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
        is $maildir->path, $SampleEmail->{'maildir'}, '->path = '.$maildir->path;
        is $maildir->kind, 'maildir', '->kind = maildir';
        isa_ok $maildir->data, $PackageName.'::Maildir';

        while( my $r = $maildir->data->read ) {
            ok length $r, 'maildir->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 37;
    }

    NOTBOUNCE: {
        my $maildir = $PackageName->new($IsNotBounce->{'maildir'});
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
        is $maildir->path, $IsNotBounce->{'maildir'}, '->path = '.$maildir->path;
        is $maildir->kind, 'maildir', '->kind = maildir';
        isa_ok $maildir->data, $PackageName.'::Maildir';

        while( my $r = $maildir->data->read ) {
            ok length $r, 'maildir->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 2;
    }

    DEVICE: {
        my $mailobj = $PackageName->new('STDIN');
        my $emindex = 0;

        isa_ok $mailobj, $PackageName;
        can_ok $mailobj, @{ $MethodNames->{'object'} };
        is $mailobj->path, 'STDIN', '->path = '.$mailobj->path;
        is $mailobj->kind, 'stdin', '->kind = stdin';
        isa_ok $mailobj->data, $PackageName.'::STDIN';
        is $emindex, 0;
    }

    MEMORY: {
        use IO::File;
        my $handler = undef;
        my $mailset = '';
        my $mailobj = undef;
        my $emindex = 0;

        MAILBOX: {
            $handler = IO::File->new($SampleEmail->{'mailbox'}, 'r');
            { local $/ = undef; $mailset = <$handler>; }
            $handler->close;
            $mailobj = $PackageName->new(\$mailset);

            isa_ok $mailobj, $PackageName;
            can_ok $mailobj, @{ $MethodNames->{'object'} };
            is $mailobj->path, 'MEMORY', '->path = '.$mailobj->path;
            is $mailobj->kind, 'memory', '->kind = memory';
            isa_ok $mailobj->data, $PackageName.'::Memory';
            is $emindex, 0;
        }

        MAILDIR: {
            $handler = IO::File->new($SampleEmail->{'maildir'}.'/make-test-01.eml', 'r');
            { local $/ = undef; $mailset = <$handler>; }
            $handler->close;
            $mailobj = $PackageName->new(\$mailset);

            isa_ok $mailobj, $PackageName;
            can_ok $mailobj, @{ $MethodNames->{'object'} };
            is $mailobj->path, 'MEMORY', '->path = '.$mailobj->path;
            is $mailobj->kind, 'memory', '->kind = memory';
            isa_ok $mailobj->data, $PackageName.'::Memory';

            is $emindex, 0;
        }
    }
}

done_testing;
