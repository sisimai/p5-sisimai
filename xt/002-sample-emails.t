use strict;
use Test::More;
use IO::File;

my $checkuntil = 2;
my $sampledirs = [
    './set-of-emails/private',
];

for my $de ( @$sampledirs ) {
    ok 1;

    next unless -d $de;
    ok -r $de;
    ok -x $de;

    opendir(my $dr, $de);
    while( my $ce = readdir $dr ) {
        next if $ce eq '.';
        next if $ce eq '..';

        ok -d sprintf("%s/%s", $de, $ce);
        ok -r sprintf("%s/%s", $de, $ce);
        ok -x sprintf("%s/%s", $de, $ce);

        opendir(my $sf, sprintf("%s/%s", $de, $ce));
        while( my $cx = readdir $sf) {
            next if $cx eq '.';
            next if $cx eq '..';

            my $emailfn = sprintf("%s/%s/%s", $de, $ce, $cx);
            my $lnindex = 0;
            my $fhandle = undef;

            ok -f $emailfn, sprintf("%s/%s: FILE", $ce, $cx);
            ok -T $emailfn, sprintf("%s/%s: TEXT", $ce, $cx);
            ok -r $emailfn, sprintf("%s/%s: READ", $ce, $cx);
            ok -s $emailfn, sprintf("%s/%s: SIZE", $ce, $cx);

            $fhandle = IO::File->new($emailfn, 'r');
            while( my $r = <$fhandle> ) {
                $lnindex++;
                like $r, qr/\x0a\z/, sprintf("%s/%s: LINE(%02d)", $ce, $cx, $lnindex);
                last if $lnindex > $checkuntil;
            }
            $fhandle->close;
        }
        close $sf;
    }
    close $dr;
}

done_testing;

