package Sisimai::Rhost;
use feature ':5.10';
use strict;
use warnings;
use Module::Load;

my $RhostClass = {
    'aspmx.l.google.com' => 'GoogleApps',
};

sub list {
    # @Description  Retrun remote host list
    # @Param        <None>
    # @Return       (Ref->Array) List
    return [ keys %$RhostClass ];
}

sub match {
    # @Description  The rhost is listed in $RhostClass or not
    # @Param <str>  (String) Remote host name
    # @Return       (Integer) 0 = did not match, 1 = match
    my $class = shift;
    my $argvs = shift // return undef;

    return 0 unless length $argvs;
    return 1 if exists $RhostClass->{ lc $argvs };
    return 0;
}

sub get {
    # @Description  Detect bounce reason from certain remote hosts
    # @Param <obj>  (Sisimai::Data) Parsed email object
    # @Return       (String) Bounce reason
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return $argvs->reason if length $argvs->reason;

    my $reasontext = '';
    my $rhostclass = __PACKAGE__.'::'.$RhostClass->{ lc $argvs->rhost } // '';

    return undef unless length $rhostclass;
    Module::Load::load( $rhostclass );
    $reasontext = $rhostclass->get( $argvs );

    return $reasontext;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Rhost - Detect the bounce reason returned from certain remote hosts.

=head1 SYNOPSIS

    use Sisimai::Rhost;

=head1 DESCRIPTION

Sisimai::Rhost detects the bounce reason from the content of Sisimai::Data
object as an argument of get() method when the value of C<rhost> of the object
is listed in the results of Sisimai::Rhost->list() method.
This class is called only Sisimai::Data class.

=head1 CLASS METHODS

=head2 C<B<list()>>

Return the list of remote hosts which is supported by Sisimai for detecting the
reason of bounce from major email services.

=head2 C<B<match( I<remote host> )>>

Returns 1 if the remote host is listed in the results of Sisimai::Rhost->list()
method.

=head2 C<B<get( I<Sisimai::Data Object> )>>

C<get()> detects the bounce reason.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
