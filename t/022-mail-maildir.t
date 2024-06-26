use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Maildir;

my $Package = 'Sisimai::Mail::Maildir';
my $Methods = {
    'class'  => ['new'],
    'object' => ['path', 'dir', 'file', 'size', 'offset', 'handle', 'read'],
};
my $MaildirSize = 589;
my $SampleEmail = './set-of-emails/maildir/bsd';
my $NewInstance = $Package->new($SampleEmail);

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };
isa_ok $NewInstance, $Package;
can_ok $NewInstance, @{ $Methods->{'object'} };

MAKETEST: {
    MAILDIR: {
        my $maildir = $Package->new($SampleEmail);
        my $emindex = 0;

        isa_ok $maildir, $Package;
        can_ok $maildir, @{ $Methods->{'object'} };
        is $maildir->dir, $SampleEmail, '->dir = '.$maildir->dir;
        is $maildir->file, undef, '->file = ""';
        is $maildir->size, $MaildirSize, '->size = '.$MaildirSize;
        is $maildir->offset, 0, '->offset = 0';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.($emindex + 1).')';
            ok length $maildir->file, '->file = '.$maildir->file;
            ok $maildir->path, '->path = '.$maildir->path;
            ok $maildir->offset, '->offset = '.$maildir->offset;
            $emindex++;
        }
        ok $emindex > 1;

        is $Package->new(undef), undef;
    }
}

done_testing;

