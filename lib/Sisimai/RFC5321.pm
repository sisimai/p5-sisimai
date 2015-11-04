package Sisimai::RFC5321;
use strict;
use warnings;

# http://www.ietf.org/rfc/rfc5321.txt
#   4.2.1.  Reply Code Severities and Theory
#       2yz  Positive Completion reply
#       3yz  Positive Intermediate reply
#       4yz  Transient Negative Completion reply
#       5yz  Permanent Negative Completion reply
#
#       x0z  Syntax: These replies refer to syntax errors, syntactically
#            correct commands that do not fit any functional category, and
#            unimplemented or superfluous commands.
#       x1z  Information: These are replies to requests for information, such
#            as status or help.
#       x2z  Connections: These are replies referring to the transmission
#            channel.
#       x3z  Unspecified.
#       x4z  Unspecified.
#       x5z  Mail system: These replies indicate the status of the receiver
#            mail system vis-a-vis the requested transfer or other mail system
#            action.
#
#  4.2.3.  Reply Codes in Numeric Order
#       211  System status, or system help reply
#       214  Help message (Information on how to use the receiver or the
#            meaning of a particular non-standard command; this reply is useful
#            only to the human user)
#       220  <domain> Service ready
#       221  <domain> Service closing transmission channel
#       250  Requested mail action okay, completed
#       251  User not local; will forward to <forward-path> (See Section 3.4)
#       252  Cannot VRFY user, but will accept message and attempt delivery
#            (See Section 3.5.3)
#       354  Start mail input; end with <CRLF>.<CRLF>
#       421  <domain> Service not available, closing transmission channel
#            (This may be a reply to any command if the service knows it must
#            shut down)
#       450  Requested mail action not taken: mailbox unavailable (e.g.,
#            mailbox busy or temporarily blocked for policy reasons)
#       451  Requested action aborted: local error in processing
#       452  Requested action not taken: insufficient system storage
#       455  Server unable to accommodate parameters
#       500  Syntax error, command unrecognized (This may include errors such
#            as command line too long)
#       501  Syntax error in parameters or arguments
#       502  Command not implemented (see Section 4.2.4)
#       503  Bad sequence of commands
#       504  Command parameter not implemented
#       550  Requested action not taken: mailbox unavailable (e.g., mailbox
#            not found, no access, or command rejected for policy reasons)
#       551  User not local; please try <forward-path> (See Section 3.4)
#       552  Requested mail action aborted: exceeded storage allocation
#       553  Requested action not taken: mailbox name not allowed (e.g.,
#            mailbox syntax incorrect)
#       554  Transaction failed (Or, in the case of a connection-opening
#            response, "No SMTP service here")
#       555  MAIL FROM/RCPT TO parameters not recognized or not implemented
#
sub getrc {
    # Get SMTP Reply Code from the given string
    # @param    [String] rtext  String including SMTP Reply Code like 550
    # @return   [String]        SMTP Reply Code or empty if the first argument
    #                           did not include SMTP Reply Code value
    my $class = shift;
    my $rtext = shift || return '';
    my $rcode = '';

    return ''   if $rtext =~ m/X-Unix;/i;
    $rcode = $1 if $rtext =~ m/\b([45][0-5][0-9])\b/;
    return $rcode;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::RFC5321 - SMTP Reply code related class

=head1 SYNOPSIS

    use Sisimai::RFC5321;
    print Sisimai::RFC5321->getrc('550 5.1.1 Unknown user');  # 550

=head1 DESCRIPTION

Sisimai::RFC5321 is utilities for getting SMTP Reply Code value from error 
message text.

=head1 CLASS METHODS

=head2 C<B<getrc( I<String> )>>

C<getdsn()> returns a SMTP Reply Code value.

    print Sisimai::RFC5321->getrc('5.0.0');                   # ''
    print Sisimai::RFC5321->getrc('550 5.1.1 User unknown');  # 550

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

