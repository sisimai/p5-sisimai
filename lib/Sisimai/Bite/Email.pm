package Sisimai::Bite::Email;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Lhost;

sub INDICATORS { Sisimai::Lhost->warn; return Sisimai::Lhost->INDICATORS }
sub headerlist { Sisimai::Lhost->warn; return Sisimai::Lhost->headerlist }
sub index      { Sisimai::Lhost->warn; return Sisimai::Lhost->index }
sub heads      { Sisimai::Lhost->warn; return Sisimai::Lhost->heads }
sub scan       { Sisimai::Lhost->warn('make'); return Sisimai::Lhost->make }
1;

__END__
=encoding utf-8

=head1 NAME

Sisimai::Bite::Email - B<OBSOLETED>: Base class for Sisimai::Bite::Email::*

=head1 SYNOPSIS

Do not use or require this class directly, use Sisimai::Bite::Email::*, such as
Sisimai::Bite::Email::Sendmail, instead.

=head1 DESCRIPTION

B<This class and child classes in Sisimai/Bite/Email will be removed at v4.25.5.>
B<Use Sisimai::Lhost and its child classes instead.>
Sisimai::Bite::Email is a base class for Sisimai::Bite::Email::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2017-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

