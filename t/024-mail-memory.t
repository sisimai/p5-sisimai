use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Memory;
use IO::File;

my $Package = 'Sisimai::Mail::Memory';
my $Methods = {
    'class'  => ['new'],
    'object' => ['path', 'size', 'offset', 'payload', 'read'],
};
my $SampleEmail = [
    './set-of-emails/mailbox/mbox-0',
    './set-of-emails/maildir/bsd/lhost-sendmail-01.eml',
];

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    is undef, $Package->new();
    is undef, $Package->new(\'');

    MAILBOX: {
        my $handler = IO::File->new($SampleEmail->[0], 'r');
        my $mailset = undef;
        my $mailobj = undef;
        my $emindex = 0;

        { local $/ = undef; $mailset = <$handler>; $handler->close }
        $mailobj = $Package->new(\$mailset);

        isa_ok $mailobj, $Package;
        can_ok $mailobj, @{ $Methods->{'object'} };
        isa_ok $mailobj->payload, 'ARRAY';
        is scalar @{ $mailobj->payload }, 37;
        is $mailobj->path, '<MEMORY>', '->path = <MEMORY>';
        is $mailobj->size, length $mailset, '->size = '.length($mailset);
        is $mailobj->offset, 0, '->offset = 0';

        while( my $r = $mailobj->read ) {
            ok length $r, 'mailobj->read('.($emindex + 1).')';
            like $r, qr/\AFrom /;
            like $r, qr/[\r\n]/;
            ok $mailobj->offset, '->offset = '.$mailobj->offset;
            $emindex++;
        }
        is $mailobj->offset, $emindex, '->offset = '.$emindex;
    }

    MAILDIR: {
        my $handler = IO::File->new($SampleEmail->[1], 'r');
        my $mailset = undef;
        my $mailobj = undef;
        my $emindex = 0;

        { local $/ = undef; $mailset = <$handler>; $handler->close }
        $mailobj = $Package->new(\$mailset);

        isa_ok $mailobj, $Package;
        can_ok $mailobj, @{ $Methods->{'object'} };
        isa_ok $mailobj->payload, 'ARRAY';
        is scalar @{ $mailobj->payload }, 1;
        is $mailobj->size, length $mailset, '->size = '.length($mailset);
        is $mailobj->offset, 0, '->offset = 0';

        while( my $r = $mailobj->read ) {
            ok length $r, 'mailobj->read('.($emindex + 1).')';
            unlike $r, qr/\AFrom /;
            like $r, qr/[\r\n]/;
            ok $mailobj->offset, '->offset = '.$mailobj->offset;
            $emindex++;
        }
        is $mailobj->offset, $emindex, '->offset = '.$emindex;
    }
}

done_testing;

