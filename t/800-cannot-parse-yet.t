use strict;
use Test::More;
use lib qw(./lib ./blib/lib);

my $CannotParse = './eg/cannot-parse-yet';

MAKE_TEST: {
    SISIMAI: {
        use Sisimai;
        my $v = Sisimai->make( $CannotParse );
        is $v, undef, 'Sisimai->make() returns undef';
    }

    MAILDIR: {
        use Sisimai::Mail::Maildir;
        my $maildir = Sisimai::Mail::Maildir->new( $CannotParse );
        my $emindex = 0;

        isa_ok $maildir, 'Sisimai::Mail::Maildir';
        is $maildir->dir, $CannotParse, '->dir = '.$maildir->dir;
        is $maildir->file, undef, '->file = ""';
        isa_ok $maildir->inodes, 'ARRAY';
        isa_ok $maildir->handle, 'IO::Dir';

        while( my $r = $maildir->read ) {
            ok length $r, 'maildir->read('.( $emindex + 1 ).')';
            ok length $maildir->file, '->file = '.$maildir->file;
            ok $maildir->path, '->path = '.$maildir->path;
            ok scalar @{ $maildir->inodes };
            $emindex++;
        }
        ok $emindex > 0;
        is $emindex, scalar @{ $maildir->inodes };
    }

    MESSAGE: {
        use Sisimai::Message;
        use IO::Dir;
        use IO::File;

        my $seekhandle = IO::Dir->new( $CannotParse );
        my $filehandle = undef;
        my $emailindir = '';
        my $mailastext = '';

        while( my $r = $seekhandle->read ) {
            # Read each file in the directory
            next if( $r eq '.' || $r eq '..' );
            $emailindir =  sprintf( "%s/%s", $CannotParse, $r );
            $emailindir =~ y{/}{}s;

            next unless -f $emailindir;
            next unless -s $emailindir;
            next unless -T $emailindir;
            next unless -r $emailindir;

            $filehandle = IO::File->new( $emailindir, 'r' );
            $mailastext = '';

            while( my $r = <$filehandle> ) {
                $mailastext .= $r;
            }
            $filehandle->close;
            ok length $mailastext, $emailindir.', size = '.length $mailastext;

            my $p = Sisimai::Message->new( 'data' => $mailastext );
            is $p, undef, 'Sisimai::Message->new() returns undef';
        }
    }
}

done_testing;


