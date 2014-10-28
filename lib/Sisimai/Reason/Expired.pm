package Sisimai::Reason::Expired;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'expired' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/connection timed out/,
        qr/delivery time expired/,
        qr/retry time not reached for any host after a long failure period/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Expired - Bounce reason is C<expired> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Expired;
    print Sisimai::Reason::Expired->match('400 Delivery time expired');   # 1

=head1 DESCRIPTION

Sisimai::Reason::Expired checks the bounce reason is C<expired> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<expired>.

    print Sisimai::Reason::Expired->text;  # expired

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Expired->match('400 Delivery time expired');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<expired>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

