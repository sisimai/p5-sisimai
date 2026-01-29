package Sisimai::Reason::Expired;
use v5.26;
use strict;
use warnings;
use Sisimai::String;

sub text  { 'expired' }
sub description { 'Delivery time has expired due to a connection failure' }
sub match {
    # Try to match that the given text and regular expressions
    # @param    [String] argv1  String to be matched with regular expressions
    # @return   [Integer]       0: Did not match
    #                           1: Matched
    # @since v4.0.0
    my $class = shift;
    my $argv1 = shift // return 0;

    state $index = [
        "connection timed out",
        "could not find a gateway for",
        "delivery attempts will continue to be",
        "failed to deliver to domain ",
        "have been failing for a long time",
        "has been delayed",
        "it has not been collected after",
        "message could not be delivered for more than",
        "message expired, ",
        "message has been in the queue too long",
        "message timed out",
        "server did not respond",
        "unable to deliver message after multiple retries",
    ];
    state $pairs = [
        ["could not be delivered for", " days"],
        ["delivery ", "expired"],
        ["not", "reach", "period"],
    ];

    return 1 if grep { rindex($argv1, $_) > -1 } @$index;
    return 1 if grep { Sisimai::String->aligned(\$argv1, $_) } @$pairs;
    return 0;
}

sub true {
    # Delivery expired due to connection failure or network error
    # @param    [Sisimai::Fact] argvs   Object to be detected the reason
    # @return   [Integer]               1: is expired
    #                                   0: is not expired
    # @see      http://www.ietf.org/rfc/rfc2822.txt
    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Expired - Bounce reason is C<expired> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Expired;
    print Sisimai::Reason::Expired->match('400 Delivery time expired');   # 1

=head1 DESCRIPTION

C<Sisimai::Reason::Expired> checks the bounce reason is C<expired> or not. This class is called only
C<Sisimai::Reason> class.

This is the error that the delivery time has expired due to a connection failure or a network error
and the message you sent has been in the queue for long time.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> method returns the fixed string C<expired>.

    print Sisimai::Reason::Expired->text;  # expired

=head2 C<B<match(I<string>)>>

C<match()> method returns C<1> if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Expired->match('400 Delivery time expired');   # 1

=head2 C<B<true(I<Sisimai::Fact>)>>

C<true()> method returns C<1> if the bounce reason is C<expired>. The argument must be C<Sisimai::Fact>
object and this method is called only from C<Sisimai::Reason> class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2016,2018,2020,2021,2024-2026 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

