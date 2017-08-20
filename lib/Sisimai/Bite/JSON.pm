package Sisimai::Bite::JSON;
use parent 'Sisimai::Bite';
use feature ':5.10';
use strict;
use warnings;

sub index {
    # @abstract Modules for parsing bounce data in JSON
    # @return   [Array] list with order
    my $class = shift;
    my $index = ['SendGrid', 'AmazonSES'];
    return $index;
}

sub scan {
    # @abstract      Convert from JSON object to Sisimai::Message
    # @param         [Hash] mhead       Message header of a bounce email
    # @param         [String] mbody     Message body of a bounce email(JSON)
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    return undef;
}

sub adapt {
    # @abstract      Adapt bounce object for Sisimai::Message format
    # @param         [Hash] argvs       bounce object returned from each email cloud
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    return undef;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::JSON - Base class for Sisimai::Bite::JSON::*: Cloud Email Delivery
Services which bounce message is JSON format.

=head1 SYNOPSIS

Do not use this class directly. Use Sisimai::Bite::JSON::* child class such as
Sisimai::Bite::JSON::SendGrid instead.

=head1 DESCRIPTION

Sisimai::Bite::JSON is a base class for Sisimai::Bite::JSON::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016-2017 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

