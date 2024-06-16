package Sisimai::Reason::MesgTooBig;
use v5.26;
use strict;
use warnings;

sub text  { 'mesgtoobig' }
sub description { 'Email rejected due to an email size is too big for a destination mail server' }
sub match {
    # Try to match that the given text and regular expressions
    # @param    [String] argv1  String to be matched with regular expressions
    # @return   [Integer]       0: Did not match
    #                           1: Matched
    # @since v4.0.0
    my $class = shift;
    my $argv1 = shift // return undef;

    state $index = [
        'exceeded maximum inbound message size',
        'line limit exceeded',
        'max message size exceeded',
        'message file too big',
        'message length exceeds administrative limit',
        'message size exceeds fixed limit',
        'message size exceeds fixed maximum message size',
        'message size exceeds maximum value',
        'message too big',
        'message too large for this ',
        'size limit',
        'taille limite du message atteinte',
    ];
    return 1 if grep { rindex($argv1, $_) > -1 } @$index;
    return 0;
}

sub true {
    # The message size is too big for the remote host
    # @param    [Sisimai::Fact] argvs   Object to be detected the reason
    # @return   [Integer]               1: is too big message size
    #                                   0: is not big
    # @since v4.0.0
    # @see http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;
    return 1 if $argvs->{'reason'} eq 'mesgtoobig';

    my $statuscode = $argvs->{'deliverystatus'} // '';
    my $tempreason = Sisimai::SMTP::Status->name($statuscode) || '';

    # Delivery status code points "mesgtoobig".
    # Status: 5.3.4
    # Diagnostic-Code: SMTP; 552 5.3.4 Error: message file too big
    return 1 if $tempreason eq 'mesgtoobig';

    #  5.2.3   Message length exceeds administrative limit
    return 0 if( $tempreason eq 'exceedlimit' || $statuscode eq '5.2.3' );
    return 1 if __PACKAGE__->match(lc $argvs->{'diagnosticcode'});
    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::MesgTooBig - Bounce reason is C<mesgtoobig> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::MesgTooBig;
    print Sisimai::Reason::MesgTooBig->match('400 Message too big');   # 1

=head1 DESCRIPTION

C<Sisimai::Reason::MesgTooBig> checks the bounce reason is C<mesgtoobig> or not. This class is
called only C<Sisimai::Reason> class.

This is the error that the sent email size is too big for the destination mail server. In many case,
There are many attachment files with the email, or the file size is too large. Sisimai will set
C<mesgtoobig> to the reason of the email bounce if the value of C<Status:> field in the bounce email
is C<5.3.4>.

    Action: failed
    Status: 553 Exceeded maximum inbound message size

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> method returns the fixed string C<mesgtoobig>.

    print Sisimai::Reason::MesgTooBig->text;  # mesgtoobig

=head2 C<B<match(I<string>)>>

C<match()> method returns C<1> if the argument matched with patterns defined in this class.

    print Sisimai::Reason::MesgTooBig->match('400 Message too big');   # 1

=head2 C<B<true(I<Sisimai::Fact>)>>

C<true()> method returns C<1> if the bounce reason is C<mesgtoobig>. The argument must be C<Sisimai::Fact>
object and this method is called only from C<Sisimai::Reason> class.

=head1 SEE ALSO

=over

=item L<Sisimai::Reason::ExceedLimit> - Sisimai::Reason::ExceedLimit

=back

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2018,2020,2021,2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

