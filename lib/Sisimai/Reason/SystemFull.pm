package Sisimai::Reason::SystemFull;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'systemfull' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/mail system full/,
        qr/requested mail action aborted: exceeded storage allocation/, # MS Exchange
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::SystemFull - Bounce reason is C<systemfull> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::SystemFull;
    print Sisimai::Reason::SystemFull->match('Mail System Full');   # 1

=head1 DESCRIPTION

Sisimai::Reason::SystemFull checks the bounce reason is C<systemfull> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<systemfull>.

    print Sisimai::Reason::SystemFull->text;  # systemfull

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::SystemFull->match('Mail System Full');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<systemfull>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
