package Sisimai::Order;
use feature ':5.10';
use strict;
use warnings;
use Module::Load;
use Sisimai::MTA;
use Sisimai::MSP;

sub default {
    # Make default order of MTA/MSP modules to be loaded
    # @return   [Array] Default order list of MTA/MSP modules
    my $class = shift;
    my $order = [];

    push @$order, map { 'Sisimai::MTA::'.$_ } @{ Sisimai::MTA->index() };
    push @$order, map { 'Sisimai::MSP::'.$_ } @{ Sisimai::MSP->index() };
    return $order;
}

sub headers {
    # Make email header list in each MTA module
    # @return   [Hash] Header list to be parsed
    # @private
    my $class = shift;

    # Load email headers from each MTA,MSP module
    my @mtaclasses = ();
    my $mtaheaders = {};
    my $ignorelist = { 'return-path' => 1 };

    push @mtaclasses, map { 'Sisimai::MTA::'.$_ } @{ Sisimai::MTA->index };
    push @mtaclasses, map { 'Sisimai::MSP::'.$_ } @{ Sisimai::MSP->index };

    LOAD_MODULES: for my $e ( @mtaclasses ) {
        # Load MTA/MSP modules
        eval { Module::Load::load $e };
        next if $@;

        for my $v ( @{ $e->headerlist } ) {
            # Get header name which required each MTA/MSP module
            my $q = lc $v;
            next if exists $ignorelist->{ $q };
            $mtaheaders->{ $q }->{ $e } = 1;
        }
    }
    return $mtaheaders;
}

sub pattern {
    # Make patterns for deciding optimized MTA/MSP order
    # @return   [Hash] Pattern based MTA/MSP module table
    my $class = shift;
    my $table = {
        'subject' => undef,
        'from'    => undef,
    };
    return $table;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Order - Make optimized order list for calling MTA/MSP modules

=head1 SYNOPSIS

    use Sisimai::Order

=head1 DESCRIPTION

Sisimai::Order makes optimized order list which include MTA/MSP modules to be
loaded on first from MTA specific headers in the bounce mail headers such as 
X-Failed-Recipients. This module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<default()>>

C<default()> returns default order of MTA/MSP modules

    print for @{ Sisimai::Order->default };

=head2 C<B<headers()>>

C<headers()> returns MTA specific header table

    print keys %{ Sisimai::Order->headers };

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
