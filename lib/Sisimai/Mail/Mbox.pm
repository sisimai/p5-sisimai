package Sisimai::Mail::Mbox;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use File::Basename 'basename';
use Try::Tiny;
use IO::File;

my $roaccessors = [
    'data',     # (String) path to mbox
    'name',     # (String) file name of the mbox
    'size',     # (Integer) File size of the mbox
];
my $rwaccessors = [
    'offset',   # (Integer) Offset position for seeking
    'handle',   # (IO::File) File handle
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );
Class::Accessor::Lite->mk_ro_accessors( @$roaccessors );

sub new {
    # @Description  Constructor of Sisimai::Mail::Mbox
    # @Param <str>  (String) Path to mbox
    # @Return       (Sisimai::Mail::Mbox) Object
    #               (undef) Undef if the argument is not a file or does not exist
    my $class = shift;
    my $argvs = shift // return undef;
    my $param = { 'offset' => 0 };

    return undef unless -e $argvs;
    return undef unless -f $argvs;

    $param->{'data'}   = $argvs;
    $param->{'size'}   = -s $argvs;
    $param->{'name'}   = File::Basename::basename $argvs;
    $param->{'handle'} = IO::File->new( $argvs, 'r' );

    return bless( $param, __PACKAGE__ );
}

sub read {
    # @Description  mbox reader, works as a iterator.
    # @Param
    # @Return       (String) Contents of mbox
    my $self = shift;

    my $seekoffset = $self->{'offset'} // 0;
    my $filehandle = $self->{'handle'};
    my $readbuffer = '';

    return undef unless defined $self->{'data'};
    return undef unless -e $self->{'data'};
    return undef unless -f $self->{'data'};
    return undef unless -T $self->{'data'};

    try {
        $seekoffset = 0 if $seekoffset < 0;
        $filehandle = IO::File->new( $self->{'data'}, 'r' ) unless eof $filehandle;

        seek( $filehandle, $seekoffset, 0 );
        while( my $r = <$filehandle> ) {
            last if( length $readbuffer && $r =~ m/\AFrom[ ]/ );
            $readbuffer .= $r;
        }
        $filehandle->close;
        $seekoffset += length $readbuffer;
        $self->{'offset'} = $seekoffset;

    } catch {
        warn $_;
    };
    return $readbuffer;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::Mail::Mbox - Mailbox reader

=head1 SYNOPSIS

    use Sisimai::Mail::Mbox;
    my $mailbox = Sisimai::Mail::Mbox->new('/var/spool/mail/root');
    while( my $r = $mailbox->read ) {
        print $r;   # print contents of each mail in mbox
    }

=head1 DESCRIPTION

Sisimai::Mail::Mbox is a mailbox file (UNIX mbox) reader.

=head1 CLASS METHODS

=head2 C<B<new( I<path to mbox> )>>

C<new()> is a constructor of Sisimai::Mail::Mbox

    my $mailbox = Sisimai::Mail::Mbox->new('/var/mail/root');

=head1 INSTANCE METHODS

=head2 C<B<data()>>

C<data()> returns the path to mbox.

    print $mailbox->data;   # /var/mail/root

=head2 C<B<name()>>

C<name()> returns a file name of the mbox.

    print $mailbox->name;   # root

=head2 C<B<size()>>

C<size()> returns the file size of the mbox.

    print $mailbox->size;   # 94515

=head2 C<B<offset()>>

C<offset()> returns offset position for seeking the mbox. The value of "offset"
is bytes which have already read.

    print $mailbox->offset;   # 0

=head2 C<B<handle()>>

C<handle()> returns file handle object (IO::File) of the mbox.

    $mailbox->handle->close;

=head2 C<B<read()>>

C<read()> works as a iterator for reading each email in the mbox.

    my $mailbox = Sisimai::Mail->new('/var/mail/neko');
    while( my $r = $mailbox->read ) {
        print $r;   # print each email in /var/mail/neko
    }

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
