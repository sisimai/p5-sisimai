use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'X2';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/norelaying/     },
    { 'n' => '01002', 'r' => qr/filtered/       },
    { 'n' => '01003', 'r' => qr/filtered/       },
    { 'n' => '01004', 'r' => qr/(?:suspend|filtered)/ },
    { 'n' => '01005', 'r' => qr/expired/        },
    { 'n' => '01006', 'r' => qr/hostunknown/    },
    { 'n' => '01007', 'r' => qr/expired/        },
    { 'n' => '01008', 'r' => qr/expired/        },
    { 'n' => '01009', 'r' => qr/mailboxfull/    },
    { 'n' => '01010', 'r' => qr/suspend/        },
    { 'n' => '01011', 'r' => qr/mailboxfull/    },
    { 'n' => '01012', 'r' => qr/suspend/        },
    { 'n' => '01013', 'r' => qr/suspend/        },
    { 'n' => '01014', 'r' => qr/suspend/        },
    { 'n' => '01015', 'r' => qr/suspend/        },
    { 'n' => '01016', 'r' => qr/suspend/        },
    { 'n' => '01017', 'r' => qr/(?:suspend|filtered)/ },
    { 'n' => '01018', 'r' => qr/suspend/        },
    { 'n' => '01019', 'r' => qr/mailboxfull/    },
    { 'n' => '01020', 'r' => qr/filtered/       },
    { 'n' => '01021', 'r' => qr/(?:filtered|suspend)/ },
    { 'n' => '01022', 'r' => qr/filtered/       },
    { 'n' => '01023', 'r' => qr/suspend/        },
    { 'n' => '01024', 'r' => qr/suspend/        },
    { 'n' => '01025', 'r' => qr/suspend/        },
    { 'n' => '01026', 'r' => qr/suspend/        },
    { 'n' => '01027', 'r' => qr/mailboxfull/    },
    { 'n' => '01028', 'r' => qr/expired/        },
    { 'n' => '01029', 'r' => qr/expired/        },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

