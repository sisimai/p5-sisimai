use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail;

my $Package = 'Sisimai::Mail';
my $Methods = { 'class'  => ['new'], 'object' => ['path', 'kind', 'data'] };
my $Samples = {
    'mailbox' => './set-of-emails/mailbox/mbox-0',
    'maildir' => './set-of-emails/maildir/err',
};
my $IsNotBounce = {
    'maildir' => './set-of-emails/maildir/not',
};

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    MAILBOX: {
        my $mailbox = $Package->new($Samples->{'mailbox'});
        my $emindex = 0;

        isa_ok $mailbox, $Package;
        can_ok $mailbox, @{ $Methods->{'object'} };
        is $mailbox->path, $Samples->{'mailbox'}, '->path = '.$mailbox->path;
        is $mailbox->kind, 'mailbox', '->kind = mailbox';
        isa_ok $mailbox->data, $Package.'::Mbox';

        while( my $r = $mailbox->data->read ) {
            ok length $r, 'mailbox->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 37;
    }

    MAILDIR: {
        my $maildir = $Package->new($Samples->{'maildir'});
        my $emindex = 0;

        isa_ok $maildir, $Package;
        can_ok $maildir, @{ $Methods->{'object'} };
        is $maildir->path, $Samples->{'maildir'}, '->path = '.$maildir->path;
        is $maildir->kind, 'maildir', '->kind = maildir';
        isa_ok $maildir->data, $Package.'::Maildir';

        while( my $r = $maildir->data->read ) {
            ok length $r, 'maildir->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 37;
    }

    NOTBOUNCE: {
        my $maildir = $Package->new($IsNotBounce->{'maildir'});
        my $emindex = 0;

        isa_ok $maildir, $Package;
        can_ok $maildir, @{ $Methods->{'object'} };
        is $maildir->path, $IsNotBounce->{'maildir'}, '->path = '.$maildir->path;
        is $maildir->kind, 'maildir', '->kind = maildir';
        isa_ok $maildir->data, $Package.'::Maildir';

        while( my $r = $maildir->data->read ) {
            ok length $r, 'maildir->data->read('.($emindex + 1).')';
            $emindex++;
        }
        is $emindex, 2;
    }

    DEVICE: {
        my $mailobj = $Package->new('STDIN');
        my $emindex = 0;

        isa_ok $mailobj, $Package;
        can_ok $mailobj, @{ $Methods->{'object'} };
        is $mailobj->path, 'STDIN', '->path = '.$mailobj->path;
        is $mailobj->kind, 'stdin', '->kind = stdin';
        isa_ok $mailobj->data, $Package.'::STDIN';
        is $emindex, 0;
    }

    MEMORY: {
        use IO::File;
        my $handler = undef;
        my $mailset = '';
        my $mailobj = undef;
        my $emindex = 0;

        MAILBOX: {
            $handler = IO::File->new($Samples->{'mailbox'}, 'r');
            { local $/ = undef; $mailset = <$handler>; }
            $handler->close;
            $mailobj = $Package->new(\$mailset);

            isa_ok $mailobj, $Package;
            can_ok $mailobj, @{ $Methods->{'object'} };
            is $mailobj->path, 'MEMORY', '->path = '.$mailobj->path;
            is $mailobj->kind, 'memory', '->kind = memory';
            isa_ok $mailobj->data, $Package.'::Memory';
            is $emindex, 0;
        }

        MAILDIR: {
            $handler = IO::File->new($Samples->{'maildir'}.'/make-test-01.eml', 'r');
            { local $/ = undef; $mailset = <$handler>; }
            $handler->close;
            $mailobj = $Package->new(\$mailset);

            isa_ok $mailobj, $Package;
            can_ok $mailobj, @{ $Methods->{'object'} };
            is $mailobj->path, 'MEMORY', '->path = '.$mailobj->path;
            is $mailobj->kind, 'memory', '->kind = memory';
            isa_ok $mailobj->data, $Package.'::Memory';

            is $emindex, 0;
        }
    }
}

done_testing;
