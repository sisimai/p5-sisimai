use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Mimecast';
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce', 'toxic'], [...]]
    '01' => [['5.4.1',   '',    'userunknown',     1, 1]],
    '02' => [['5.7.54',  '550', 'norelaying',      0, 1]],
};

$enginetest->($enginename, $isexpected);
done_testing;

