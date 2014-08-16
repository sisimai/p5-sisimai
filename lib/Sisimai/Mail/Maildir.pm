package Sisimai::Mail::Maildir;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Try::Tiny;
use IO::Dir;
use IO::File;

my $roaccessors = [
    'data',     # (String) path to Maildir/
];
my $rwaccessors = [
    'name',     # (String) file name of a mail in the Maildir/
    'files',    # (Ref->Array) i-node list of files in the Maildir/
    'handle',   # (IO::File) File handle
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );
Class::Accessor::Lite->mk_ro_accessors( @$roaccessors );

sub new {
    # @Description  Constructor of Sisimai::Mail::Maildir
    # @Param <str>  (String) Path to Maildir/
    # @Return       (Sisimai::Mail::Maildir) Object
    #               (undef) Undef if the argument is not a directory or does not exist
    my $class = shift;
    my $argvs = shift // return undef;
    my $param = { 'files' => [] };

    return undef unless -e $argvs;
    return undef unless -d $argvs;

    $param->{'data'}   = $argvs;
    $param->{'name'}   = undef;
    $param->{'files'}  = [];
    $param->{'handle'} = IO::Dir->new( $argvs );

    return bless( $param, __PACKAGE__ );
}

sub read {
    # @Description  Maildir reader, works as a iterator.
    # @Param
    # @Return       (String) Contents of file in Maildir/
    my $self = shift;

    return undef unless defined $self->{'data'};
    return undef unless -e $self->{'data'};
    return undef unless -d $self->{'data'};

    my $seekhandle = $self->{'handle'};
    my $filehandle = undef;
    my $readbuffer = '';
    my $emailindir = '';
    my $emailinode = undef;

    try {
        $seekhandle = IO::Dir->new( $self->{'data'} ) unless $seekhandle;

        while( my $r = $seekhandle->read ) {
            # Read each file in the directory
            next if( $r eq '.' || $r eq '..' );

            $emailindir =  sprintf( "%s/%s", $self->{'data'}, $r );
            $emailindir =~ y{/}{}s;
            next unless -f $emailindir;
            next unless -s $emailindir;
            next unless -T $emailindir;
            next unless -r $emailindir;

            # Get inode number of the file
            $emailinode = [ stat $emailindir ]->[1];
            next if grep { $emailinode == $_ } @{ $self->{'files'} };

            $filehandle = IO::File->new( $emailindir, 'r' );
            while( my $f = <$filehandle> ) {
                # Concatenate the contents of each file
                $readbuffer .= $f;
            }
            $filehandle->close;

            push @{ $self->{'files'} }, $emailinode;
            $self->{'name'} = $r;

            last;
        }

    } catch {
        warn $_;
    };
    return $readbuffer;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::Mail::Maildir - Mailbox reader

=head1 SYNOPSIS

    use Sisimai::Mail::Maildir;
    my $maildir = Sisimai::Mail::Maildir->new('/home/neko/Maildir/new');
    while( my $r = $maildir->read ) {
        print $r;   # print contents of the mail in the Maildir/
    }

=head1 DESCRIPTION

Sisimai::Mail::Maildir is a reader for getting contents of each email in the
Maildir/ directory.

=head1 CLASS METHODS

=head2 C<B<new( I<path to Maildir/> )>>

C<new()> is a constructor of Sisimai::Mail::Maildir

    my $maildir = Sisimai::Mail::Maildir->new('/home/neko/Maildir/new');

=head1 INSTANCE METHODS

=head2 C<B<data()>>

C<data()> returns the path to Maildir.

    print $maildir->data;   # /home/neko/Maildir/new

=head2 C<B<name()>>

C<name()> returns current file name of the Maildir.

    print $maildir->name;

=head2 C<B<files()>>

C<name()> returns i-node list of each email in Maildir.

    print for @{ $maildir->files };

=head2 C<B<handle()>>

C<handle()> returns file handle object (IO::Dir) of the Maildir.

    $maildir->handle->close;

=head2 C<B<read()>>

C<read()> works as a iterator for reading each email in the Maildir.

    my $maildir = Sisimai::Mail->new('/home/neko/Maildir/new');
    while( my $r = $mailbox->read ) {
        print $r;   # print each email in /home/neko/Maildir/new
    }

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
