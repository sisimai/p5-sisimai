package Sisimai::Bite::JSON;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Lhost;

sub INDICATORS { Sisimai::Lhost->warn('gone'); return Sisimai::Lhost->INDICATORS }
sub index      { Sisimai::Lhost->warn('gone'); return ['AmazonSES', 'SendGrid']  }
sub scan       { Sisimai::Lhost->warn('gone'); return Sisimai::Lhost->make  }
sub adapt      { Sisimai::Lhost->warn('gone'); return undef }
1;

__END__

=encoding utf-8

=head1 NAME

Sisimai::Bite::JSON - B<OBSOLETED>: Base class for Sisimai::Bite::JSON::*: Cloud Email Delivery
Services which bounce message is JSON format.

=head1 SYNOPSIS

Do not use this class directly. Use Sisimai::Bite::JSON::* child class such as
Sisimai::Bite::JSON::SendGrid instead.

=head1 DESCRIPTION

B<This class and child classes in Sisimai/Bite/JSON will be removed at v4.25.5.>
Sisimai::Bite::JSON is a base class for Sisimai::Bite::JSON::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

