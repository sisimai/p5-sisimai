package Sisimai::Mail;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load '';

my $roaccessors = [
    'path',     # (String) path to mbox or Maildir/
    'type',     # (String) Data type: mailbox, maildir, or stdin
];
my $rwaccessors = [
    'mail',     # (Object) ::Mbox or ::Maildir
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );
Class::Accessor::Lite->mk_ro_accessors( @$roaccessors );

sub new {
    # @Description  Constructor of Sisimai::Mail
    # @Param <str>  (String) Path to mbox or Maildir/
    # @Return       (Sisimai::Mail) Object
    #               (undef) Undef if the argument was wrong
    my $class = shift;
    my $argvs = shift;
    my $klass = undef;
    my $param = { 
        'type' => '', 
        'mail' => undef,
        'path' => $argvs,
    };

    $param->{'path'} = $argvs;

    # The argumenet is a mailbox or a Maildir/.
    if( -f $argvs ) {
        # The argument is a file, it is an mbox
        $klass = sprintf( "%s::Mbox", __PACKAGE__ );
        $param->{'type'} = 'mailbox';

    } elsif( -d $argvs ) {
        # The agument is not a file, it is a Maildir/
        $klass = sprintf( "%s::Maildir", __PACKAGE__ );
        $param->{'type'} = 'maildir';

    } else {
        # The argument neither a mailbox nor a Maildir/.
        if( $argvs eq '<STDIN>' || ref $argvs eq 'IO::Handle' ) {
            # Read from STDIN
            $klass = sprintf( "%s::STDIN", __PACKAGE__ );
            $param->{'type'} = 'stdin';
        }
    }

    return undef unless $klass;
    Module::Load::load $klass;
    $param->{'mail'} = $klass->new( $argvs );

    return bless( $param, __PACKAGE__ );
}

sub read {
    # @Description  mbox/Maildir reader, works as a iterator.
    # @Param        <None>
    # @Return       (String) Contents of mbox/Maildir
    my $self = shift;
    my $mail = $self->{'mail'};

    return undef unless ref $mail;
    return $mail->read;
}

sub close {
    # @Description  Close the handle
    # @Param        <None>
    # @Return
    my $self = shift;
    return 0 unless $self->{'mail'}->{'handle'};

    $self->{'mail'}->{'handle'} = undef;
    return 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Mail - Handler of Mbox/Maildir for reading each mail.

=head1 SYNOPSIS

    use Sisimai::Mail;
    my $mailbox = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mailbox->read ) {
        print $r;
    }
    $mailbox->close;

    my $maildir = Sisimai::Mail->new('/home/neko/Maildir/cur');
    while( my $r = $maildir->read ) {
        print $r;
    }
    $maildir->close;


=head1 DESCRIPTION

Sisimai::Mail is a handler of UNIX mbox or Maildir for reading each mail. It is
wrapper class of Sisimai::Mail::Mbox and Sisimai::Mail::Maildir classes.

=head1 CLASS METHODS

=head2 C<B<new( I<path to mbox|Maildir/> )>>

C<new()> is a constructor of Sisimai::Mail

    my $mailbox = Sisimai::Mail->new('/var/mail/root');
    my $maildir = Sisimai::Mail->new('/home/nyaa/Maildir/cur');

=head1 INSTANCE METHODS

=head2 C<B<path()>>

C<path()> returns the path to mbox or Maildir.

    print $mailbox->path;   # /var/mail/root

=head2 C<B<mbox()>>

C<type()> Returns the name of data type

    print $mailbox->type;   # mailbox or maildir, or stdin.

=head2 C<B<mail()>>

C<mail()> returns Sisimai::Mail::Mbox object or Sisimai::Mail::Maildir object.

    my $o = $mailbox->mail;
    print ref $o;   # Sisimai::Mail::Mbox

=head2 C<B<read()>>

C<read()> works as a iterator for reading each email in mbox or Maildir. It calls
Sisimai::Mail::Mbox->read or Sisimai::Mail::Maildir->read method.

    my $mailbox = Sisimai::Mail->new('/var/mail/neko');
    while( my $r = $mailbox->read ) {
        print $r;   # print each email in /var/mail/neko
    }
    $mailbox->close;

=head2 C<B<close()>>

C<close()> Close the handle of the mailbox or the maildir.

    my $o = $mailbox->close;
    print $o;   # 1 = Successfully closed, 0 = already closed.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
