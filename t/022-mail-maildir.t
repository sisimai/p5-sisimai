use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Maildir;

my $PackageName = 'Sisimai::Mail::Maildir';
my $MethodNames = {
    'class' => [ 'new' ],
    'object' => [ 'data', 'name', 'files', 'handle', 'read' ],
};
my $SampleEmail = './eg/maildir-as-a-sample/cur';
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
        is $maildir->data, $SampleEmail, '->data = '.$maildir->data;
        is $maildir->name, undef, '->name = ""';
        isa_ok $maildir->files, 'ARRAY';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.( $emindex + 1 ).')';
            ok length $maildir->name, '->name = '.$maildir->name;
            ok scalar @{ $maildir->files };
            $emindex++;
        }
        is $emindex, 37;
    }
}

done_testing;

