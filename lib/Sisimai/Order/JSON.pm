package Sisimai::Order::JSON;
use parent 'Sisimai::Order';
use feature ':5.10';
use strict;
use warnings;

sub default {
    # Make default order of MTA modules to be loaded
    # @return   [Array] Default order list of MTA modules
    # @since v4.13.1
    my $class = shift; $class->SUPER::warn('forjson');
    return $class->SUPER::forjson;
}

sub by {
    # Get regular expression patterns for specified key name
    # @param    [String] group  Group name for "ORDER BY"
    # @return   [Hash]          Pattern table for the group
    # @since v4.13.2
    my $class = shift; $class->SUPER::warn('gone');
    return $class->SUPER::by(shift);
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Order::JSON - B<OBSOLETED>: Make optimized order list for calling MTA modules

=head1 SYNOPSIS

    use Sisimai::Order::JSON

=head1 DESCRIPTION

B<This class will be removed at v4.25.5.>
Sisimai::Order::JSON makes optimized order list which include MTA modules to be
loaded on first from bounce object key names in the decoded JSON object. This
module are called from only Sisimai::Message::JSON.

This class was marked as obsoleted at v4.25.4 and will be removed at the future
release of Sisimai.

=head1 CLASS METHODS

=head2 C<B<default()>>

C<default()> returns default order of MTA modules

    print for @{ Sisimai::Order::JSON->default };

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

