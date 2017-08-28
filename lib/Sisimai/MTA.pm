package Sisimai::MTA;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC5322;
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
    # MTA list
    # @return   [Array] MTA list with order
    warn sprintf(" ***warning: %s->index has been moved to Sisimai::Bite::Email->index\n", __PACKAGE__);
    my $class = shift;
    my $index = [
        'Sendmail', 'Postfix', 'qmail', 'Exim', 'Courier', 'OpenSMTPD', 
        'Exchange2007', 'Exchange2003', 'MessagingServer', 'Domino', 'Notes',
        'ApacheJames', 'McAfee', 'MXLogic', 'MailFoundry', 'IMailServer', 
        'mFILTER', 'Activehunter', 'InterScanMSS', 'SurfControl', 'MailMarshalSMTP',
        'X1', 'X2', 'X3', 'X4', 'X5', 'V5sendmail', 
    ];
    return $index;
}

sub scan {
    # Detect an error
    # @param         [Hash] mhead       Message header of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    warn sprintf(" ***warning: %s->scan has been moved to Sisimai::Bite::Email->scan\n", __PACKAGE__);
    return undef;
}

1;

package Sisimai::MTA::Activehunter; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::ApacheJames; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Courier; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Domino; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Exchange2003; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Exchange2007; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Exim; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::IMailServer; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::InterScanMSS; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::MXLogic; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::MailFoundry; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::MailMarshalSMTP; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::McAfee; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::MessagingServer; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Notes; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::OpenSMTPD; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Postfix; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::Sendmail; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::SurfControl; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::UserDefined; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::V5sendmail; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::X1; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::X2; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::X3; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::X4; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::X5; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::mFILTER; use parent 'Sisimai::MTA'; 1; 
package Sisimai::MTA::qmail; use parent 'Sisimai::MTA'; 1; 

__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA - Base class for Sisimai::MTA::*

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::MTA::*, such as Sisimai::MTA::Sendmail,
instead.

=head1 DESCRIPTION

Sisimai::MTA is a base class for Sisimai::MTA::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2017 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
