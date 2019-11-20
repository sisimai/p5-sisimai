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
