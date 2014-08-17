package Sisimai::Reason::ContentError;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'contenterror' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/message header size, or recipient list, exceeds policy limit/,
        qr/message mime complexity exceeds the policy maximum/,
        qr/routing loop detected -- too many received: headers/,
        qr/the headers in this message contain improperly-formatted binary content/,
        qr/this message contains invalid MIME headers/,
        qr/this message contains improperly-formatted binary content/,
        qr/this message contains text that uses unnecessary base64 encoding/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::ContentError - Bounce reason is C<contenterror> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::ContentError;
    print Sisimai::Reason::ContentError->match('550 Message Filterd'); # 1

=head1 DESCRIPTION

Sisimai::Reason::ContentError checks the bounce reason is C<contenterror> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<contenterror>.

    print Sisimai::Reason::ContentError->text;  # contenterror

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::ContentError->match('550 Message Filterd'); # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<contenterror>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

