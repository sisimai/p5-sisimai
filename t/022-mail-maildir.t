use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Maildir;

my $PackageName = 'Sisimai::Mail::Maildir';
my $MethodNames = {
    'class' => ['new'],
    'object' => ['path', 'dir', 'file', 'size', 'offset', 'handle', 'read'],
};
my $MaildirSize = 488;
my $SampleEmail = './set-of-emails/maildir/bsd';
my $NewInstance = $PackageName->new($SampleEmail);

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };

MAKE_TEST: {
    MAILDIR: {
        my $maildir = $PackageName->new($SampleEmail);
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
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
    }
}

done_testing;

