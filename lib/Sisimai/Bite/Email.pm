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
