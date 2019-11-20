use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'IMailServer';
my $samplepath = sprintf("./set-of-emails/private/email-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/hostunknown/  },
    { 'n' => '01002', 'r' => qr/mailboxfull/  },
    { 'n' => '01003', 'r' => qr/userunknown/  },
    { 'n' => '01004', 'r' => qr/userunknown/  },
    { 'n' => '01005', 'r' => qr/mailboxfull/  },
    { 'n' => '01006', 'r' => qr/userunknown/  },
    { 'n' => '01007', 'r' => qr/userunknown/  },
    { 'n' => '01008', 'r' => qr/hostunknown/  },
    { 'n' => '01009', 'r' => qr/expired/      },
    { 'n' => '01010', 'r' => qr/expired/      },
    { 'n' => '01011', 'r' => qr/userunknown/  },
    { 'n' => '01012', 'r' => qr/mailboxfull/  },
    { 'n' => '01013', 'r' => qr/userunknown/  },
    { 'n' => '01014', 'r' => qr/hostunknown/  },
    { 'n' => '01015', 'r' => qr/userunknown/  },
    { 'n' => '01016', 'r' => qr/expired/      },
    { 'n' => '01017', 'r' => qr/expired/      },
    { 'n' => '01018', 'r' => qr/mailboxfull/  },
    { 'n' => '01019', 'r' => qr/mailboxfull/  },
    { 'n' => '01020', 'r' => qr/undefined/    },
    { 'n' => '01021', 'r' => qr/mailboxfull/  },
    { 'n' => '01022', 'r' => qr/userunknown/  },
    { 'n' => '01023', 'r' => qr/mailboxfull/  },
    { 'n' => '01024', 'r' => qr/undefined/    },
    { 'n' => '01025', 'r' => qr/userunknown/  },
    { 'n' => '01026', 'r' => qr/userunknown/  },
    { 'n' => '01027', 'r' => qr/userunknown/  },
    { 'n' => '01028', 'r' => qr/userunknown/  },
    { 'n' => '01029', 'r' => qr/userunknown/  },
    { 'n' => '01030', 'r' => qr/hostunknown/  },
    { 'n' => '01031', 'r' => qr/hostunknown/  },
    { 'n' => '01032', 'r' => qr/undefined/    },
    { 'n' => '01033', 'r' => qr/userunknown/  },
    { 'n' => '01034', 'r' => qr/userunknown/  },
    { 'n' => '01035', 'r' => qr/spamdetected/ },
    { 'n' => '01036', 'r' => qr/spamdetected/ },
    { 'n' => '01037', 'r' => qr/spamdetected/ },
    { 'n' => '01038', 'r' => qr/mailboxfull/  },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

