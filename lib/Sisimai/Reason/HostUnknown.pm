package Sisimai::Reason::HostUnknown;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'hostunknown' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/recipient domain must exist/,    # qmail ?
        qr/host or domain name not found/,
        qr/host unknown/,
        qr/host unreachable/,
        qr/name or service not known/,
        qr/no such domain/,
        qr/recipient address rejected: unknown domain name/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Whether the host is unknown or not
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is unknown host 
    #               (Integer) 0 = is not unknown host.
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
        # Status: 5.1.2
        # Diagnostic-Code: SMTP; 550 Host unknown
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

Sisimai::Reason::HostUnknown - Bounce reason is C<hostunknown> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::HostUnknown;
    print Sisimai::Reason::HostUnknown->match('550 5.2.1 Host Unknown');   # 1

=head1 DESCRIPTION

Sisimai::Reason::HostUnknown checks the bounce reason is C<hostunknown> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<hostunknown>.

    print Sisimai::Reason::HostUnknown->text;  # hostunknown

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::HostUnknown->match('550 5.2.1 Host Unknown');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<hostunknown>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
