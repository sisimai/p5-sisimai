package Sisimai::RFC1123;
use v5.26;
use strict;
use warnings;

sub is_validhostname {
    # Check that the argument is a valid hostname or not
    # @param    [String] argv0  String to be checked
    # @return   [Boolean]       0: is not a valid hostname
    #                           1: is a valid hostname
    my $class = shift;
    my $argv0 = shift || return 0;
    my $valid = 1;
    my $token = [split(/\./, $argv0)] || ['0'];

    return 0 if length $argv0 > 255;
    return 0 if index($argv0, ".") == -1;
    return 0 if index($argv0, "..") > -1;
    return 0 if index($argv0, "--") > -1;
    return 0 if index($argv0, ".") ==  0;
    return 0 if index($argv0, "-") ==  0;
    return 0 if substr($argv0, -1, 1) eq "-";

    for my $e (split("", uc $argv0)) {
        # Check each character (upper-cased)
        my $f = ord $e;
        $valid = 0 if $f <  45;            # 45 = '-'
        $valid = 0 if $f == 47;            # 47 = '/'
        $valid = 0 if $f >  57 && $f < 65; # 57 = '9', 65 = 'A'
        $valid = 0 if $f >  90             # 90 = 'Z'
    }
    return 0 if $valid == 0;
    return 0 if $token->[-1] =~ /\d/;
    return $valid;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::RFC1123 - Hostname related class

=head1 SYNOPSIS

    use Sisimai::RFC1123;

    print Sisimai::RFC1123->is_validhostname("mx2.example.jp"); # 1
    print Sisimai::RFC1123->is_validhostname("localhost");      # 0


=head1 DESCRIPTION

C<Sisimai::RFC1123> is a class related to the Internet hosts

=head1 CLASS METHODS

=head2 C<B<is_validhostname(I<String>)>>

C<is_validhostname()> method returns true when the argument is a valid hostname

    print Sisimai::RFC1123->is_validhostname("mx2.example.jp"); # 1
    print Sisimai::RFC1123->is_validhostname("localhost");      # 0

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

