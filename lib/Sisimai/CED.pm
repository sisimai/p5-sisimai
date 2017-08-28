package Sisimai::CED;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Skeleton;

sub DELIVERYSTATUS {
    warn sprintf(" ***warning: %s->DELIVERYSTATUS has been moved to Sisimai::Bite->DELIVERYSTATUS\n", __PACKAGE__);
    return Sisimai::Skeleton->DELIVERYSTATUS;
}
sub INDICATORS {
    warn sprintf(" ***warning: %s->DELIVERYSTATUS has been moved to Sisimai::Bite::Email->INDICATORS\n", __PACKAGE__);
    return Sisimai::Skeleton->INDICATORS;
}
sub smtpagent { 
    warn sprintf(" ***warning: %s->smtpagent has been moved to Sisimai::Bite->smtpagent\n", __PACKAGE__);
    my $v = shift;
    $v =~ s/\ASisimai:://;
    return $v;
}
sub description {
    warn sprintf(" ***warning: %s->description has been moved to Sisimai::Bite->description\n", __PACKAGE__);
    return '';
}
sub headerlist {
    warn sprintf(" ***warning: %s->headerlist has been moved to Sisimai::Bite::Email->headerlist\n", __PACKAGE__);
    return [];
}
sub pattern {
    warn sprintf(" ***warning: %s->pattern has been moved to Sisimai::Bite::Email->pattern\n", __PACKAGE__);
    return {};
}

sub index {
    # CED list
    # @return   [Array] CED list with order
    my $class = shift;
    my $index = ['US::AmazonSES', 'US::SendGrid'];
    return $index;
}

sub scan {
    # Convert from JSON object to Sisimai::Message
    # @param         [Hash] mhead       Message header of a bounce email
    # @param         [String] mbody     Message body of a bounce email(JSON)
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    return undef;
}

sub adapt {
    # Adapt bounce object for Sisimai::Message format
    # @param         [Hash] argvs       bounce object returned from each email cloud
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    return undef;
}

1;

package Sisimai::CED::US::AmazonSES; use parent 'Sisimai::CED'; 1;
package Sisimai::CED::US::SendGrid; use parent 'Sisimai::CED'; 1;

__END__

=encoding utf-8

=head1 NAME

Sisimai::CED - Base class for Sisimai::CED::*: Cloud Email Delivery Services

=head1 SYNOPSIS

Do not use this class directly. Use Sisimai::CED::* child class such as
Sisimai::CED::US::AmazonSES instead.

=head1 DESCRIPTION

Sisimai::CED is a base class for Sisimai::CED::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016-2017 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
