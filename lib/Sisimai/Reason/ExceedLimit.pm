package Sisimai::Reason::ExceedLimit;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'exceedlimit' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/message too large/,  # Postfix
    ];
    # return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Exceed limit or not
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = exceeds the limit
    #               (Integer) 0 = does not exceed the limit
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;

    return undef unless length $statuscode;
    return 1 if $argvs->reason eq $reasontext;

    require Sisimai::RFC3463;
    my $diagnostic = $argvs->diagnosticcode // '';
    my $v = 0;

    if( Sisimai::RFC3463->reason( $statuscode ) eq $reasontext ) {
        # Delivery status code points C<exceedlimit>.
        # Status: 5.2.3
        # Diagnostic-Code: SMTP; 552 5.2.3 Message size exceeds fixed maximum message size
        $v = 1;

    } else {
        # Check the value of Diagnosic-Code: header with patterns
        $v = 1 if __PACKAGE__->match( $diagnostic );
    }

    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::ExceedLimit - Bounce reason is C<exceedlimit> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::ExceedLimit;
    print Sisimai::Reason::ExceedLimit->match; # 0

=head1 DESCRIPTION

Sisimai::Reason::ExceedLimit checks the bounce reason is C<exceedlimit> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<exceedlimit>.

    print Sisimai::Reason::ExceedLimit->text;  # exceedlimit

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::ExceedLimit->match; # 0;

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<exceedlimit>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
