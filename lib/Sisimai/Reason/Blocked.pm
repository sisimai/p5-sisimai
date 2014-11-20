package Sisimai::Reason::Blocked;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'blocked' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        # Blocked due to clent IP address or hostname
        qr/access from ip address .+ blocked/,
        qr/client host rejected: may not be mail exchanger/,
        qr/connection refused by/,
        qr/connection reset by peer/,
        qr/hosts with dynamic ip/,
        qr/no access from mail server/,
        qr/unresolvable relay host name/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Blocked due to client IP address or hostname
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is blocked
    #               (Integer) 0 = is not blocked by the client
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return 1 if $argvs->reason eq __PACKAGE__->text;

    require Sisimai::RFC3463;
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;
    my $tempreason = '';
    my $diagnostic = '';
    my $v = 0;

    $tempreason = Sisimai::RFC3463->reason( $statuscode ) if $statuscode;
    $diagnostic = $argvs->diagnosticcode // '';

    if( $tempreason eq $reasontext ) {
        # Delivery status code points "blocked".
        $v = 1;

    } else {
        # Matched with a pattern in this class
        $v = 1 if __PACKAGE__->match( $diagnostic );
    }
    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Blocked - Bounce reason is C<blocked> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Blocked;
    print Sisimai::Reason::Blocked->match('Access from ip address 192.0.2.1 blocked'); # 1

=head1 DESCRIPTION

Sisimai::Reason::Blocked checks the bounce reason is C<blocked> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<blocked>.

    print Sisimai::Reason::Blocked->text;  # blocked

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Blocked->match('Access from ip address 192.0.2.1 blocked');  # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<blocked>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
