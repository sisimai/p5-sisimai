use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Memory;
use IO::File;

my $PackageName = 'Sisimai::Mail::Memory';
my $MethodNames = {
    'class' => ['new'],
    'object' => ['size', 'type', 'offset', 'data', 'read'],
};
my $SampleEmail = [
    './set-of-emails/mailbox/mbox-0',
    './set-of-emails/maildir/bsd/email-sendmail-01.eml',
    './set-of-emails/jsonobj/json-amazonses-01.json',
];

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    MAILBOX: {
        my $handler = IO::File->new($SampleEmail->[0], 'r');
        my $mailset = undef;
        my $mailobj = undef;
        my $emindex = 0;

        { local $/ = undef; $mailset = <$handler>; $handler->close }
        $mailobj = $PackageName->new(\$mailset);

        isa_ok $mailobj, $PackageName;
        can_ok $mailobj, @{ $MethodNames->{'object'} };
        isa_ok $mailobj->data, 'ARRAY';
        is scalar @{ $mailobj->data }, 37;
        is $mailobj->size, length $mailset, '->size = '.length($mailset);
        is $mailobj->type, 'mbox', '->type = mbox';
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
        $mailobj = $PackageName->new(\$mailset);

        isa_ok $mailobj, $PackageName;
        can_ok $mailobj, @{ $MethodNames->{'object'} };
        isa_ok $mailobj->data, 'ARRAY';
        is scalar @{ $mailobj->data }, 1;
        is $mailobj->size, length $mailset, '->size = '.length($mailset);
        is $mailobj->type, 'mail', '->type = mail';
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

    JSONOBJ: {
        use JSON;
        my $handler = IO::File->new($SampleEmail->[2], 'r');
        my $jsontxt = undef;
        my $mailobj = undef;
        my $emindex = 0;
        my $jsonobj = undef;

        { local $/ = undef; $jsontxt = <$handler>; $handler->close }
        $mailobj = $PackageName->new(\$jsontxt);

        isa_ok $mailobj, $PackageName;
        can_ok $mailobj, @{ $MethodNames->{'object'} };
        isa_ok $mailobj->data, 'ARRAY';
        is scalar @{ $mailobj->data }, 1;
        is $mailobj->size, length $jsontxt, '->size = '.length($jsontxt);
        is $mailobj->type, 'json', '->type = json';
        is $mailobj->offset, 0, '->offset = 0';

        while( my $r = $mailobj->read ) {
            ok length $r, 'mailobj->read('.($emindex + 1).')';
            unlike $r, qr/\AFrom /;
            like $r, qr/[\r\n]/;
            ok $mailobj->offset, '->offset = '.$mailobj->offset;

            $jsonobj = JSON::decode_json($r);
            isa_ok $jsonobj, 'HASH';
            isa_ok $jsonobj->{'bounce'}, 'HASH';
            ok length $jsonobj->{'notificationType'};

            $emindex++;
        }
        is $mailobj->offset, $emindex, '->offset = '.$emindex;
    }
}

done_testing;

