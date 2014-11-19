package Sisimai::Reason::SystemError;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'systemerror' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        # Postfix
        qr/can[']t create user output file/,
        qr/mail forwarding loop for /,
        qr/mail for .+ loops back to myself/,
        qr/mail system configuration error/,
        qr/server configuration error/,

        qr/host is unreachable/,
        qr/interrupted system call/,
        qr/local configuration error/,
        qr/local error in processing/,
        qr/mail system configuration error/,
        qr/maximum forwarding loop count exceeded/,
        qr/server configuration error/,
        qr/system config error/,
        qr/timeout waiting for input/,
        qr/too many hops/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::SystemError - Bounce reason is C<systemerror> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::SystemError;
    print Sisimai::Reason::SystemError->match('5.3.5 System config error'); # 1

=head1 DESCRIPTION

Sisimai::Reason::SystemError checks the bounce reason is C<systemerror> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<systemerror>.

    print Sisimai::Reason::SystemError->text;  # systemerror

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::SystemError->match('5.3.5 System config error'); # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<systemerror>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
