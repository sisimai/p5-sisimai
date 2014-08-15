package Sisimai::Reason::MesgTooBig;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'mesgtoobig' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/message file too big/,
        qr/message length exceeds administrative limit/,
        qr/message size exceeds fixed limit/,
        qr/message size exceeds fixed maximum message size/,
        qr/message size exceeds maximum value/,
        qr/message too big/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  The message size is too big for the remote host
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is too big message size
    #               (Integer) 0 = is not big
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
        # Delivery status code points "mailboxfull".
        # Status: 5.3.4
        # Diagnostic-Code: SMTP; 552 5.3.4 Error: message file too big
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

Sisimai::Reason::MesgTooBig - Bounce reason is C<mesgtoobig> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::MesgTooBig;
    print Sisimai::Reason::MesgTooBig->match('400 Message too big');   # 1

=head1 DESCRIPTION

Sisimai::Reason::MesgTooBig checks the bounce reason is C<mesgtoobig> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<mesgtoobig>.

    print Sisimai::Reason::MesgTooBig->text;  # mesgtoobig

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::MesgTooBig->match('400 Message too big');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<mesgtoobig>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
