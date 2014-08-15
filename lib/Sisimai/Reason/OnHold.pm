package Sisimai::Reason::OnHold;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'onhold' }
sub match { return 0 }
sub true  {
    # @Description  On hold, Could not decide the bounce reason...
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = Status code is C<onhold>
    #               (Integer) 0 = is not C<onhold>
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;

    return undef unless length $statuscode;
    return 1 if $argvs->reason eq $reasontext;

    require Sisimai::RFC3463;
    return 1 if Sisimai::RFC3463->reason( $statuscode ) eq $reasontext;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::OnHold - Bounce reason is C<onhold> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::OnHold;
    print Sisimai::Reason::OnHold->match; # 0

=head1 DESCRIPTION

Sisimai::Reason::OnHold checks the bounce reason is C<onhold> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<onhold>.

    print Sisimai::Reason::OnHold->text;  # onhold

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::OnHold->match; # 0;

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<onhold>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
