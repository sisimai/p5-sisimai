use strict;
use Test::More;
use lib qw(./lib ./blib/lib);

my $CannotParse = './set-of-emails/to-be-debugged-because/sisimai-cannot-parse-yet';
plan 'skip_all', sprintf("%s does not exist", $CannotParse) unless -d $CannotParse;

MAKETEST: {
    SISIMAI: {
        use Sisimai;
        my $v = Sisimai->rise($CannotParse);
        is $v, undef, 'Sisimai->rise() returns undef';
    }

    MAILDIR: {
        use Sisimai::Mail::Maildir;
        my $maildir = Sisimai::Mail::Maildir->new($CannotParse);
        my $emindex = 0;

        isa_ok $maildir, 'Sisimai::Mail::Maildir';
        is $maildir->dir, $CannotParse, '->dir = '.$maildir->dir;
        is $maildir->file, undef, '->file = ""';
        isa_ok $maildir->inodes, 'HASH';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.($emindex + 1).')';
            ok length $maildir->file, '->file = '.$maildir->file;
            ok $maildir->path, '->path = '.$maildir->path;
            ok scalar keys %{ $maildir->inodes };
            $emindex++;
        }
        ok $emindex > 0;
        is $emindex, scalar keys %{ $maildir->inodes };
    }

    MESSAGE: {
        use Sisimai::Message;
        use IO::Dir;
        use IO::File;

        my $seekhandle = IO::Dir->new($CannotParse);
        my $filehandle = undef;
        my $emailindir = '';
        my $mailastext = '';

        while( my $r = $seekhandle->read ) {
            # Read each file in the directory
            next if( $r eq '.' || $r eq '..' );
            $emailindir =  sprintf("%s/%s", $CannotParse, $r);
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

            my $p = Sisimai::Message->new('data' => $mailastext);
            is $p, undef, 'Sisimai::Message->new() returns undef';
        }
    }
}

done_testing;

