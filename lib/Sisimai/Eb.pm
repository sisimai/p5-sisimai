package Sisimai::Eb;
use v5.26;
use strict;
use warnings;

#       _       ______                            
#   ___| |__   / /  _ \ ___  __ _ ___  ___  _ __  
#  / _ \ '_ \ / /| |_) / _ \/ _` / __|/ _ \| '_ \ 
# |  __/ |_) / / |  _ <  __/ (_| \__ \ (_) | | | |
#  \___|_.__/_/  |_| \_\___|\__,_|___/\___/|_| |_|
our $ReAUTH = "AuthFailure";
our $ReFAMA = "BadReputation";
our $ReBLOC = "Blocked";
our $ReBODY = "ContentError";
our $ReSENT = "Delivered";
our $ReSIZE = "EmailTooLarge";
our $ReTIME = "Expired";
our $ReTTLS = "FailedSTARTTLS";
our $ReFEED = "Feedback";
our $ReFILT = "Filtered";
our $ReMOVE = "HasMoved";
our $ReHOST = "HostUnknown";
our $ReFULL = "MailboxFull";
our $ReUNIX = "MailerError";
our $ReINET = "NetworkError";
our $RePASS = "NoRelaying";
our $Re00MX = "NotAccept";
our $ReNRFC = "NotCompliantRFC";
our $Re___1 = "OnHold";
our $ReWONT = "PolicyViolation";
our $ReFROM = "Rejected";
our $ReQPTR = "RequirePTR";
our $ReRATE = "RateLimited";
our $ReSAFE = "SecurityError";
our $ReSPAM = "SpamDetected";
our $ReSTOP = "Suppressed";
our $ReQUIT = "Suspend";
our $ReCOMM = "SyntaxError";
our $RePROC = "SystemError";
our $ReDISK = "SystemFull";
our $Re___0 = "Undefined";
our $ReUSER = "UserUnknown";
our $ReAWAY = "Vacation";
our $ReEXEC = "VirusDetected";

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Eb - Constants for email bounce

=head1 SYNOPSIS

    use Sisimai::Eb;
    print $Sisimai::Eb::ReAUTH; # AuthFailure

=head1 DESCRIPTION

C<Sisimai::Eb> keep constants referred from many classes in Sisimai.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2026 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

