use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Mbox;

my $PackageName = 'Sisimai::Mail::Mbox';
my $MethodNames = {
    'class' => [ 'new' ],
    'object' => [ 'data', 'name', 'size', 'handle', 'offset', 'read' ],
};
my $SampleEmail = './eg/mbox-as-a-sample';
my $NewInstance = $PackageName->new( $SampleEmail );

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };

MAKE_TEST: {
    MAILBOX: {
        my $mailbox = $PackageName->new( $SampleEmail );
        my $emindex = 0;

        isa_ok $mailbox, $PackageName;
        can_ok $mailbox, @{ $MethodNames->{'object'} };
        is $mailbox->data, $SampleEmail, '->data = '.$SampleEmail;
        is $mailbox->name, 'mbox-as-a-sample', '->name = mbox-as-a-sample';
        is $mailbox->size, -s $SampleEmail, '->size = 94515';
        isa_ok $mailbox->handle, 'IO::File';
        is $mailbox->offset, 0, '->offset = 0';

        while( my $r = $mailbox->read ) {
            ok length $r, 'mailbox->read('.( $emindex + 1 ).')';
            ok $mailbox->offset, '->offset = '.$mailbox->offset;
            $emindex++;
        }
        is $mailbox->offset, -s $SampleEmail;
        is $emindex, 37;
    }
}

done_testing;

