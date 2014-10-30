package Sisimai::Reason::Suspend;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'suspend' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/recipient suspend the service/,
        qr/sorry your message to .+ cannot be delivered[.] this account has been disabled or discontinued/,
        qr/vdelivermail: account is locked email bounced/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Suspend - Bounce reason is C<suspend> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Suspend;
    print Sisimai::Reason::Suspend->match('recipient suspend the service'); # 1

=head1 DESCRIPTION

Sisimai::Reason::Suspend checks the bounce reason is C<suspend> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<suspend>.

    print Sisimai::Reason::Suspend->text;  # suspend

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Suspend->match('recipient suspend the service'); # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<suspend>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
