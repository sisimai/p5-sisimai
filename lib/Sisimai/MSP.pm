package Sisimai::MSP;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::MTA;

sub version     { return '4.0.6' }
sub description { return '' }
sub headerlist  { return [] }

sub SMTPCOMMAND    { return Sisimai::MTA->SMTPCOMMAND    }
sub EOM            { return Sisimai::MTA->EOM            }
sub DELIVERYSTATUS { return Sisimai::MTA->DELIVERYSTATUS }
sub RFC822HEADERS  { 
    my $class = shift;
    my $argvs = shift;
    return Sisimai::MTA->RFC822HEADERS( $argvs );
}

sub smtpagent {
    my $class = shift; 
    return shift // 'null';
}

sub index {
    # @Description  MSP list
    # @Param        None
    # @Return       (Ref->Array) MSP list with order
    my $class = shift;
    my $index = [
        'US::Google', 'US::Yahoo', 'US::Aol', 'US::Outlook',
        'US::AmazonSES', 'US::SendGrid',
        'JP::EZweb', 'JP::KDDI', 'JP::Biglobe',
        'US::Verizon', 'RU::MailRu', 'DE::GMX', 'US::Facebook',
    ];

    return $index;
}

sub scan {
    # @Description  Detect an error
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    return '';
#     my $RxMSP = {};
# 
#     my $class = shift;
#     my $mhead = shift // return undef;
#     my $mbody = shift // return undef;
# 
#     # return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};
#     # return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};
# 
#     my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
#     my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
#     my $rfc822part = '';    # (String) message/rfc822-headers part
#     my $previousfn = '';    # (String) Previous field name
# 
#     my $stripedtxt = [ split( "\n", $$mbody ) ];
#     my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
#     my $rcptintext = '';    # (String) Recipient address in the message body
#     my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
#     my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
#     my $connheader = {
#         'date'    => '',    # The value of Arrival-Date header
#         'lhost'   => '',    # The value of Received-From-MSP header
#         'rhost'   => '',    # The value of Reporting-MSP header
#     };
# 
#     my $v = undef;
#     my $p = '';
#     push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
#     $rfc822head = __PACKAGE__->RFC822HEADERS;
# 
#     # 1. Email headers in the bounce mail
#     # 2. Delivery status
#     # 3. message/rfc822 part
#     # 4. Original message
#     for my $e ( @$stripedtxt ) {
#         # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
#         if( ( grep { $e =~ $_ } @{ $RxMSP->{'rfc822'} } ) .. ( $e =~ $RxMSP->{'endof'} ) ) {
#             # After "message/rfc822"
# 
#         } else {
#             # Before "message/rfc822"
#             next unless ( $e =~ $RxMSP->{'begin'} ) .. ( grep { $e =~ $_ } @{ $RxMSP->{'rfc822'} } );
#             next unless length $e;
# 
#             if( $connvalues == scalar( keys %$connheader ) ) {
#                 # Parse delivery status
#             } else {
#                 # Get headers related the smtp session/connection
#             }
#         } # End of if: rfc822
# 
#     } continue {
#         # Save the current line for the next loop
#         $p = $e;
#         $e = '';
#     }
# 
#     return undef unless $recipients;
#     for my $e ( @$dscontents ) {
#         # Set default values if each value is empty.
#         for my $f ( 'date', 'lhost', 'rhost' ) {
#             $e->{ $f }  ||= $connheader->{ $f } || '';
#         }
#         $e->{'agent'}   ||= __PACKAGE__->smtpagent;
#         $e->{'command'} ||= $commandtxt;
#     }
#     return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP - Base class for Sisimai::MSP::*, Mail Service Provider classes.

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::MSP::*, such as Sisimai::MSP::Google,
instead.

=head1 DESCRIPTION

Sisimai::MSP is a base class for Sisimai::MSP::*.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
