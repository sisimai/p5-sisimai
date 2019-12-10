package Sisimai::Order::Email;
use parent 'Sisimai::Order';
use feature ':5.10';
use strict;
use warnings;

sub by {
    # Get regular expression patterns for specified field
    # @param    [String] group  Group name for "ORDER BY"
    # @return   [Hash]          Pattern table for the group
    # @since v4.13.2
    my $class = shift; $class->SUPER::warn('');
    return $class->SUPER::by(shift);
}

sub default {
    # Make default order of MTA modules to be loaded
    # @return   [Array] Default order list of MTA modules
    # @since v4.13.1
    my $class = shift; $class->SUPER::warn('');
    return $class->SUPER::default;
}

sub another {
    # Make MTA modules list as a spare
    # @return   [Array] Ordered module list
    # @since v4.13.1
    my $class = shift; $class->SUPER::warn('');
    return $class->SUPER::another;
};

sub headers {
    # Make email header list in each MTA module
    # @return   [Hash] Header list to be parsed
    # @since v4.13.1
    my $class = shift; $class->SUPER::warn('');
    return $class->SUPER::headers;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Order::Email - B<OBSOLETED>: Make optimized order list for calling MTA modules

=head1 SYNOPSIS

    use Sisimai::Order::Email

=head1 DESCRIPTION

B<This class has been merged into Sisimai::Order at v4.25.4 and will be removed at v4.25.5.>
Sisimai::Order::Email makes optimized order list which include MTA modules to
be loaded on first from MTA specific headers in the bounce mail headers such as
X-Failed-Recipients. This module are called from only Sisimai::Message::Email.

This class was marked as obsoleted at v4.25.4 and will be removed at the future
release of Sisimai.

=head1 CLASS METHODS

=head2 C<B<default()>>

C<default()> returns default order of MTA modules

    print for @{ Sisimai::Order::Email->default };

=head2 C<B<headers()>>

C<headers()> returns MTA specific header table

    print keys %{ Sisimai::Order::Email->headers };

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

