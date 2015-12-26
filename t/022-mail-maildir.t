use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Maildir;

my $PackageName = 'Sisimai::Mail::Maildir';
my $MethodNames = {
    'class' => [ 'new' ],
    'object' => [ 'path', 'dir', 'file', 'inodes', 'handle', 'read' ],
};
my $SampleEmail = './set-of-emails/maildir/bsd';
my $NewInstance = $PackageName->new( $SampleEmail );

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };

MAKE_TEST: {
    MAILDIR: {
        my $maildir = $PackageName->new( $SampleEmail );
        my $emindex = 0;

        isa_ok $maildir, $PackageName;
        can_ok $maildir, @{ $MethodNames->{'object'} };
        is $maildir->dir, $SampleEmail, '->dir = '.$maildir->dir;
        is $maildir->file, undef, '->file = ""';
        isa_ok $maildir->inodes, 'HASH';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.( $emindex + 1 ).')';
            ok length $maildir->file, '->file = '.$maildir->file;
            ok $maildir->path, '->path = '.$maildir->path;
            ok scalar keys %{ $maildir->inodes };
            $emindex++;
        }
        ok $emindex > 1;
        is $emindex, scalar keys %{ $maildir->inodes };
    }
}

done_testing;

