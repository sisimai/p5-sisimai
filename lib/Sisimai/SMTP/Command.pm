package Sisimai::SMTP::Command;
use feature ':5.10';
use strict;
use warnings;

sub test {
    # Check that an SMTP command in the argument is valid or not
    # @param    [String] argv0  An SMTP command
    # @return   [Boolean]       0: Is not a valid SMTP command, 1: Is a valid SMTP command
    # @since v5.0.0
    my $class = shift;
    my $argv0 = shift // return undef;

    return undef unless length $argv0 > 3;
    return 1 if grep { index($argv0, $_) > -1 } (qw|HELO EHLO MAIL RCPT DATA QUIT AUTH STARTTLS|);
    return 1 if index($argv0, 'CONN') > -1; # CONN is a pseudo SMTP command used only in Sisimai
    return 0;
}

sub find {
    # Pick an SMTP command from the given string
    # @param    [String] argv0  A transcript text MTA returned
    # @return   [String]        An SMTP command
    # @return   [undef]         Failed to find an SMTP command or the 1st argument is missing
    # @since v5.0.0
    my $class = shift;
    my $argv0 = shift // return undef;
    return undef unless __PACKAGE__->test($argv0);

    state $detectable = [
        'HELO', 'EHLO', 'STARTTLS', 'AUTH PLAIN', 'AUTH LOGIN', 'AUTH CRAM-', 'AUTH DIGEST-',
        'MAIL F', 'RCPT', 'RCPT T', 'DATA'
    ];
    my $stringsize = length $argv0;
    my $commandset = [];
    my $previouspp = 0;

    for my $e ( @$detectable ) {
        # Find an SMTP command from the given string
        my $p = index $argv0, $e, $previouspp;
        next if $p < 0;
        last if $p + 4 > $stringsize;
        $previouspp = $p;

        my $v = substr($argv0, $p, 4); next if grep { $v eq $_ } @$commandset;
           $v = 'STARTTLS' if $v eq 'STAR';
        push @$commandset, $v;
    }
    return undef unless scalar @$commandset;
    return pop @$commandset;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::SMTP::Command - SMTP Command related utilities

=head1 SYNOPSIS

    use Sisimai::SMTP::Command;
    Sisimai::SMTP::Command->find('in reply to RCPT TO command');  # RCPT

=head1 DESCRIPTION

Sisimai::SMTP::Command is a class for finding the last SMTP command from given error message.

=head1 CLASS METHODS

=head2 C<B<test(I<String>)>>

C<test()> checks whether an SMTP command is a valid command or not

    print Sisimai::SMTP::Command->test('STARTTLS'); # 1
    print Sisimai::SMTP::Command->test('NEKO');     # 0

=head2 C<B<find(I<String>)>>

C<find()> returns the last SMTP command like the following:

    print Sisimai::SMTP::Command->find('MAIL FROM: <> 250 OK RCPT TO: <...> 550');  # "RCPT"

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2022-2023 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

