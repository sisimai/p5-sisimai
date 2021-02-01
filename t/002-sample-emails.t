use strict;
use Test::More;
use IO::File;

my $checkuntil = 2;
my $sampledirs = [
    './set-of-emails/mailbox',
    './set-of-emails/maildir/err',
    './set-of-emails/maildir/bsd',
    './set-of-emails/maildir/dos',
    './set-of-emails/to-be-debugged-because/something-is-wrong',
    './set-of-emails/to-be-parsed-for-test',
];

for my $de ( @$sampledirs ) {
    ok -d $de;
    ok -r $de;
    ok -x $de;
    opendir(my $dr, $de);
    while( my $ce = readdir $dr ) {
        next if $ce eq '.';
        next if $ce eq '..';

        my $emailfn = sprintf("%s/%s", $de, $ce);
        my $lnindex = 0;
        my $fhandle = undef;

        next unless -f $emailfn;
        ok -T $emailfn, sprintf("%s: TEXT", $ce);
        ok -r $emailfn, sprintf("%s: READ", $ce);
        ok -s $emailfn, sprintf("%s: SIZE", $ce);

        $fhandle = IO::File->new($emailfn, 'r');
        while( my $r = <$fhandle> ) {
            $lnindex++;
            like $r, qr/\x0a\z/, sprintf("%s: LINE(%02d)", $ce, $lnindex);
            last if $lnindex > $checkuntil;
        }
        $fhandle->close;
    }
    close $dr;
}

done_testing;

