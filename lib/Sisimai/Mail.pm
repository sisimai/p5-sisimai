package Sisimai::Mail;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load;

my $roaccessors = [
    'data',     # (String) path to mbox or Maildir/
    'mbox',     # (Integer) if the value of data is an mbox, this value is 1.
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
    my $argvs = shift // return undef;
    my $param = { 'mbox' => 1, 'mail' => undef };
    my $klass = undef;

    return undef unless -e $argvs;
    return undef if( ! -f $argvs && ! -d $argvs );

    $param->{'mbox'} = 0 unless -f $argvs;
    $param->{'data'} = $argvs;

    if( -f $argvs ) {
        # The argument is a file, it is an mbox
        $klass = sprintf( "%s::Mbox", __PACKAGE__ );
    } else {
        # The agument is not a file, it is a Maildir/
        $klass = sprintf( "%s::Maildir", __PACKAGE__ );
    }
    Module::Load::load $klass;
    $param->{'mail'} = $klass->new( $argvs );

    return bless( $param, __PACKAGE__ );
}

sub read {
    # @Description  mbox/Maildir reader, works as a iterator.
    # @Param
    # @Return       (String) Contents of mbox/Maildir
    my $self = shift;
    my $mail = $self->{'mail'};

    return undef unless ref $mail;
    return $mail->read;
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

    my $maildir = Sisimai::Mail->new('/home/neko/Maildir/cur');
    while( my $r = $maildir->read ) {
        print $r;
    }


=head1 DESCRIPTION

Sisimai::Mail is a handler of UNIX mbox or Maildir for reading each mail. It is
wrapper class of Sisimai::Mail::Mbox and Sisimai::Mail::Maildir classes.

=head1 CLASS METHODS

=head2 C<B<new( I<path to mbox|Maildir/> )>>

C<new()> is a constructor of Sisimai::Mail

    my $mailbox = Sisimai::Mail->new('/var/mail/root');
    my $maildir = Sisimai::Mail->new('/home/nyaa/Maildir/cur');

=head1 INSTANCE METHODS

=head2 C<B<data()>>

C<data()> returns the path to mbox or Maildir.

    print $mailbox->data;   # /var/mail/root

=head2 C<B<mbox()>>

C<mbox()> returns 1 if the value of "data" is a file

    print $mailbox->mbox;   # 1

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

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
