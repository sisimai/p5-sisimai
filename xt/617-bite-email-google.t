use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Google';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/expired/         },
    { 'n' => '01002', 'r' => qr/suspend/         },
    { 'n' => '01003', 'r' => qr/expired/         },
    { 'n' => '01004', 'r' => qr/filtered/        },
    { 'n' => '01005', 'r' => qr/expired/         },
    { 'n' => '01006', 'r' => qr/filtered/        },
    { 'n' => '01007', 'r' => qr/userunknown/     },
    { 'n' => '01008', 'r' => qr/expired/         },
    { 'n' => '01009', 'r' => qr/expired/         },
    { 'n' => '01010', 'r' => qr/userunknown/     },
    { 'n' => '01011', 'r' => qr/mailboxfull/     },
    { 'n' => '01012', 'r' => qr/expired/         },
    { 'n' => '01013', 'r' => qr/mailboxfull/     },
    { 'n' => '01014', 'r' => qr/userunknown/     },
    { 'n' => '01015', 'r' => qr/filtered/        },
    { 'n' => '01016', 'r' => qr/filtered/        },
    { 'n' => '01017', 'r' => qr/filtered/        },
    { 'n' => '01018', 'r' => qr/userunknown/     },
    { 'n' => '01019', 'r' => qr/userunknown/     },
    { 'n' => '01020', 'r' => qr/userunknown/     },
    { 'n' => '01021', 'r' => qr/userunknown/     },
    { 'n' => '01022', 'r' => qr/userunknown/     },
    { 'n' => '01023', 'r' => qr/userunknown/     },
    { 'n' => '01024', 'r' => qr/blocked/         },
    { 'n' => '01025', 'r' => qr/filtered/        },
    { 'n' => '01026', 'r' => qr/filtered/        },
    { 'n' => '01027', 'r' => qr/securityerror/   },
    { 'n' => '01028', 'r' => qr/systemerror/     },
    { 'n' => '01029', 'r' => qr/onhold/          },
    { 'n' => '01030', 'r' => qr/blocked/         },
    { 'n' => '01031', 'r' => qr/blocked/         },
    { 'n' => '01032', 'r' => qr/expired/         },
    { 'n' => '01033', 'r' => qr/blocked/         },
    { 'n' => '01034', 'r' => qr/expired/         },
    { 'n' => '01035', 'r' => qr/expired/         },
    { 'n' => '01036', 'r' => qr/expired/         },
    { 'n' => '01037', 'r' => qr/blocked/         },
    { 'n' => '01038', 'r' => qr/userunknown/     },
    { 'n' => '01039', 'r' => qr/userunknown/     },
    { 'n' => '01040', 'r' => qr/(?:expired|undefined)/ },
    { 'n' => '01041', 'r' => qr/userunknown/     },
    { 'n' => '01042', 'r' => qr/userunknown/     },
    { 'n' => '01043', 'r' => qr/userunknown/     },
    { 'n' => '01044', 'r' => qr/policyviolation/ },
    { 'n' => '01045', 'r' => qr/expired/         },
    { 'n' => '01046', 'r' => qr/userunknown/     },
    { 'n' => '01047', 'r' => qr/userunknown/     },
    { 'n' => '01048', 'r' => qr/mailboxfull/     },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

