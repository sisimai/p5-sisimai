use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Mbox;

my $Package = 'Sisimai::Mail::Mbox';
my $Methods = {
    'class'  => ['new'],
    'object' => ['path', 'dir', 'file', 'size', 'handle', 'offset', 'read'],
};
my $SampleEmail = './set-of-emails/mailbox/mbox-0';
my $NewInstance = $Package->new($SampleEmail);

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };
isa_ok $NewInstance, $Package;
can_ok $NewInstance, @{ $Methods->{'object'} };

MAKETEST: {
    MAILBOX: {
        my $mailbox = $Package->new($SampleEmail);
        my $emindex = 0;

        isa_ok $mailbox, $Package;
        can_ok $mailbox, @{ $Methods->{'object'} };
        is $mailbox->dir, './set-of-emails/mailbox', '->dir = ./set-of-emails/mailbox';
        is $mailbox->path, $SampleEmail, '->path = '.$SampleEmail;
        is $mailbox->file, 'mbox-0', '->file = mbox-0';
        is $mailbox->size, -s $SampleEmail, '->size = 96906';
        isa_ok $mailbox->handle, 'IO::File';
        is $mailbox->offset, 0, '->offset = 0';

        while( my $r = $mailbox->read ) {
            ok length $r, 'mailbox->read('.($emindex + 1).')';
            ok $mailbox->offset, '->offset = '.$mailbox->offset;
            $emindex++;
        }
        is $mailbox->offset, -s $SampleEmail;
        is $emindex, 37;

        is $Package->new(undef), undef;
    }
}

done_testing;

