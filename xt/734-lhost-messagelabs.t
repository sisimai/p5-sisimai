use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'MessageLabs';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'userunknown',     1]],
    '01002' => [['5.0.0',   '550', 'securityerror',   0]],
    '01003' => [['5.0.0',   '',    'userunknown',     1]],
    '01004' => [['5.0.0',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

