use strict;
use Test::More;
use lib qw(./lib ./blib/lib);

my $ShouldNotCrash = './set-of-emails/should-not-crash';
plan 'skip_all', sprintf("%s does not exist", $ShouldNotCrash) unless -d $ShouldNotCrash;

MAKETEST: {
    MAILDIR: {
        use Sisimai::Mail::Maildir;
        my $maildir = Sisimai::Mail::Maildir->new($ShouldNotCrash);
        my $emindex = 0;

        isa_ok $maildir, 'Sisimai::Mail::Maildir';
        is $maildir->dir, $ShouldNotCrash, '->dir = '.$maildir->dir;
        is $maildir->file, undef, '->file = ""';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.($emindex + 1).')';
            ok length $maildir->file, '->file = '.$maildir->file;
            ok $maildir->path, '->path = '.$maildir->path;
            $emindex++;
        }
        ok $emindex > 0;
    }

    MESSAGE: {
        use Sisimai;
        use IO::Dir;
        use IO::File;

        my $seekhandle = IO::Dir->new($ShouldNotCrash);
        my $filehandle = undef;
        my $emailindir = '';
        my $mailastext = '';

        while( my $r = $seekhandle->read ) {
            # Read each file in the directory
            next if( $r eq '.' || $r eq '..' );
            $emailindir =  sprintf("%s/%s", $ShouldNotCrash, $r);
            $emailindir =~ y{/}{}s;

            next unless -f $emailindir;
            next unless -s $emailindir;
            next unless -T $emailindir;
            next unless -r $emailindir;

            $filehandle = IO::File->new($emailindir, 'r');
            $mailastext = '';

            while( my $f = <$filehandle> ) {
                $mailastext .= $f;
            }
            $filehandle->close;
            ok length $mailastext, $emailindir.', size = '.length $mailastext;

            my $p = Sisimai->rise($emailindir);
            is $p, undef, 'Sisimai->rise('.$r.') returns undef';
        }
    }
}

done_testing;

