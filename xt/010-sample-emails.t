use strict;
use Test::More;
use IO::File;

my $checkuntil = 2;
my $publicfile = [
    './set-of-emails/maildir/err',
    './set-of-emails/maildir/bsd',
    './set-of-emails/maildir/dos',
    './set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet',
    './set-of-emails/to-be-debugged-because/reason-is-undefined',
];
my $privatefile = './set-of-emails/private';

PUBLIC_SAMPLES: {
    for my $d ( @$publicfile ) {
        ok -d $d;
        my $h = undef;

        opendir( $h, $d );
        while( my $e = readdir $h ) {

            next if $e eq '.';
            next if $e eq '..';

            my $emailfn = sprintf( "%s/%s", $d, $e );
            my $lnindex = 0;
            my $fhandle = undef;

            next unless -f $emailfn;
            ok -T $emailfn, sprintf( "%s: TEXT", $e );
            ok -r $emailfn, sprintf( "%s: READ", $e );
            ok -s $emailfn, sprintf( "%s: SIZE", $e );

            $fhandle = IO::File->new( $emailfn, 'r' );
            while( my $r = <$fhandle> ) {
                $lnindex++;
                like $r, qr/\x0a\z/, sprintf( "%s: LINE(%02d)", $e, $lnindex );
                last if $lnindex > $checkuntil;
            }
            $fhandle->close;
        }
        close $h;
    }
}

PRIVATE_SAMPLES: {
    last unless -d $privatefile;

    my $dir0 = undef;
    my $dir1 = undef;

    opendir( $dir0, $privatefile );
    while( my $e = readdir $dir0 ) {

        next if $e eq '.';
        next if $e eq '..';
        my $tablemodel;
        my $directory1 = sprintf( "%s/%s", $privatefile, $e );

        opendir( $dir1, $directory1 );
        while( my $f = readdir $dir1 ) {
            next if $e eq '.';
            next if $e eq '..';

            my $emailfn = sprintf( "%s/%s", $directory1, $f );
            my $lnindex = 0;
            my $fhandle = undef;

            next unless -f $emailfn;
            ok -T $emailfn, sprintf( "%s: TEXT", $f );
            ok -r $emailfn, sprintf( "%s: READ", $f );
            ok -s $emailfn, sprintf( "%s: SIZE", $f );

            $fhandle = IO::File->new( $emailfn, 'r' );
            while( my $r = <$fhandle> ) {
                $lnindex++;
                like $r, qr/\x0a\z/, sprintf( "%s: LINE(%02d)", $f, $lnindex );
                last if $lnindex > $checkuntil;
            }
            $fhandle->close;
        }
        close $dir1;
    }
    close $dir0;
}
done_testing;

