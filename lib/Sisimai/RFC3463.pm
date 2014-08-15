package Sisimai::RFC3463;
use strict;
use warnings;

# http://www.ietf.org/rfc/rfc1893.txt
# http://www.ietf.org/rfc/rfc3463.txt
# http://www.ietf.org/rfc/rfc5248.txt
#
#  4.X.X   Persistent Transient Failure
#  5.X.X   Permanent Failure
#
#  X.0.X   Other or Undefined Status 
#  X.1.X   Addressing Status
#  X.2.X   Mailbox Status
#  X.3.X   Mail System Status
#  X.4.X   Network and Routing Status
#  X.5.X   Mail Delivery Protocol Status
#  X.6.X   Message Content or Media Status
#  X.7.X   Security or Policy Status
#
#  X.0.0   Other undefined Status
#  X.1.0   Other address status
#  X.1.1   Bad destination mailbox address
#  X.1.2   Bad destination system addres
#  X.1.3   Bad destination mailbox address syntax
#  X.1.4   Destination mailbox address ambiguous
#  X.1.5   Destination address valid
#  X.1.6   Destination mailbox has moved, No forwarding address
#  X.1.7   Bad sender's mailbox address syntax
#  X.1.8   Bad sender's system address
#  X.1.9   Message relayed to non-compliant mailer (RFC 5248, 3886)
#
#  X.2.0   Other or undefined mailbox status
#  X.2.1   Mailbox disabled, not accepting messages
#  X.2.2   Mailbox full
#  X.2.3   Message length exceeds administrative limit
#  X.2.4   Mailing list expansion problem
#
#  X.3.0   Other or undefined mail system status
#  X.3.1   Mail system full
#  X.3.2   System not accepting network messages
#  X.3.3   System not capable of selected features
#  X.3.4   Message too big for system
#  X.3.5   System incorrectly configured
#
#  X.4.0   Other or undefined network or routing status
#  X.4.1   No answer from host
#  X.4.2   Bad connection
#  X.4.3   Directory server failure
#  X.4.4   Unable to route
#  X.4.5   Mail system congestion
#  X.4.6   Routing loop detected
#  X.4.7   Delivery time expired
#  
#  X.5.0   Other or undefined protocol status
#  X.5.1   Invalid command
#  X.5.2   Syntax error
#  X.5.3   Too many recipients
#  X.5.4   Invalid command arguments
#  X.5.5   Wrong protocol version
#  X.5.6   Authentication Exchange line is too long (RFC 5248, 4954)
#
#  X.6.0   Other or undefined media error
#  X.6.1   Media not supported
#  X.6.2   Conversion required and prohibited
#  X.6.3   Conversion required but not supported
#  X.6.4   Conversion with loss performed
#  X.6.5   Conversion Failed
#  X.6.6   Message content not available (RFC 5248, 4468)
#  X.6.7   The ALT-ADDRESS is required but not specified (RFC 5336)
#  X.6.8   UTF-8 string reply is required, but not permitted by the client (RFC 5336)
#  X.6.9   UTF8SMTP downgrade failed (RFC 5336)
#  X.6.10  UTF-8 string reply is required, but not permitted by the client (RFC 5336)
#
#  X.7.0   Other or undefined security status
#  X.7.1   Delivery not authorized, message refused
#  X.7.2   Mailing list expansion prohibited
#  X.7.3   Security conversion required but not possibl
#  X.7.4   Security features not supported
#  X.7.5   Cryptographic failure
#  X.7.6   Cryptographic algorithm not supported
#  X.7.7   Message integrity failure
#  X.7.8   Trust relationship required (RFC 5248, 4468)
#  X.7.10  Encryption Needed (RFC 5248)
#  X.7.13  User Account Disabled (RFC 5248)
#  X.7.14  Trust relationship required (RFC 5248)
#
# -------------------------------------------------------------------------
# http://www.ietf.org/rfc/rfc3886.txt
#  3.3.4.  Status field
#
#   The Status field is defined as in RFC 3464.  A new code is added to
#   RFC 3463 [RFC-EMSSC], "Enhanced Mail System Status Codes",
#
#      X.1.9   Message relayed to non-compliant mailer"
#
#         The mailbox address specified was valid, but the message has
#         been relayed to a system that does not speak this protocol; no
#         further information can be provided.
#
#   A 2.1.9 Status field MUST be used exclusively with a "relayed" Action
#   field.  This field is REQUIRED.
#
# -------------------------------------------------------------------------
# http://www.ietf.org/rfc/rfc4468.txt
#  5.  Updates to RFC 3463
#
#   SMTP or Submit servers that advertise ENHANCEDSTATUSCODES [RFC2034]
#   use enhanced status codes defined in RFC 3463 [RFC3463].  The BURL
#   extension introduces new error cases that that RFC did not consider.
#   The following additional enhanced status codes are defined by this
#   specification:
#
#   X.6.6 Message content not available
#
#      The message content could not be fetched from a remote system.
#      This may be useful as a permanent or persistent temporary
#      notification.
#
#   X.7.8 Trust relationship required
#
#      The submission server requires a configured trust relationship
#      with a third-party server in order to access the message content.
# 
#  6.  Response Codes
#
#   This section includes example response codes to the BURL command.
#   Other text may be used with the same response codes.  This list is
#   not exhaustive, and BURL clients MUST tolerate any valid SMTP
#   response code.  Most of these examples include the appropriate
#   enhanced status code [RFC3463].
#
#   554 5.5.0 No recipients have been specified
#   503 5.5.0 Valid RCPT TO required before BURL
#   554 5.6.3 Conversion required but not supported
#   554 5.3.4 Message too big for system
#   554 5.7.8 URL resolution requires trust relationship
#   552 5.2.2 Mailbox full
#   554 5.6.6 IMAP URL resolution failed
#   250 2.5.0 Waiting for additional BURL or BDAT commands
#   451 4.4.1 IMAP server unavailable
#   250 2.5.0 Ok.
#   250 2.6.4 MIME header conversion with loss performed
#  
# -------------------------------------------------------------------------
# http://www.ietf.org/rfc/rfc4954.txt
#  6.  Status Codes
#
#   The following error codes may be used to indicate various success or
#   failure conditions.  Servers that return enhanced status codes
#   [ESMTP-CODES] SHOULD use the enhanced codes suggested here.
#
#   235 2.7.0  Authentication Succeeded
#   432 4.7.12 A password transition is needed
#   454 4.7.0  Temporary authentication failure
#   534 5.7.9  Authentication mechanism is too weak
#   535 5.7.8  Authentication credentials invalid
#   500 5.5.6  Authentication Exchange line is too long
#   530 5.7.0  Authentication required
#   538 5.7.11 Encryption required for requested authentication
#
#       5.7.8  Authentication credentials invalid
#       5.7.9  Authentication mechanism is too weak
#       5.7.11 Encryption required for requested authentication mechanism
#
#   X.5.6     Authentication Exchange line is too long
#
#   This enhanced status code SHOULD be returned when the server fails
#   the AUTH command due to the client sending a [BASE64] response which
#   is longer than the maximum buffer size available for the currently
#   selected SASL mechanism.  This is useful for both permanent and
#   persistent transient errors.
#  
# -------------------------------------------------------------------------
# http://www.ietf.org/rfc/rfc5248.txt
# 
#   Code:               X.7.10
#   Sample Text:        Encryption Needed
#   Associated basic status code:  523
#   Description:        This indicates that an external strong privacy
#                       layer is needed in order to use the requested
#                       authentication mechanism.  This is primarily
#                       intended for use with clear text authentication
#                       mechanisms.  A client that receives this may
#                       activate a security layer such as TLS prior to
#                       authenticating, or attempt to use a stronger
#                       mechanism.
#   Reference:          RFC 5248 (Best current practice)
#   Submitter:          T. Hansen, J. Klensin
#   Change controller:  IESG
#
#   Code:               X.7.13
#   Sample Text:        User Account Disabled
#   Associated basic status code:  525
#   Description:        Sometimes a system administrator will have to
#                       disable a user's account (e.g., due to lack of
#                       payment, abuse, evidence of a break-in attempt,
#                       etc.).  This error code occurs after a successful
#                       authentication to a disabled account.  This
#                       informs the client that the failure is permanent
#                       until the user contacts their system
#                       administrator to get the account re-enabled.  It
#                       differs from a generic authentication failure
#                       where the client's best option is to present the
#                       passphrase entry dialog in case the user simply
#                       mistyped their passphrase.
#   Reference:          RFC 5248 (Best current practice)
#   Submitter:          T. Hansen, J. Klensin
#   Change controller:  IESG
#
#   Code:               X.7.14
#   Sample Text:        Trust relationship required
#   Associated basic status code:  535, 554
#   Description:        The submission server requires a configured trust
#                       relationship with a third-party server in order
#                       to access the message content.  This value
#                       replaces the prior use of X.7.8 for this error
#                       condition, thereby updating [RFC4468].
#   Reference:          RFC 5248 (Best current practice)
#   Submitter:          T. Hansen, J. Klensin
#   Change controller:  IESG
#
# -------------------------------------------------------------------------
# http://www.ietf.org/rfc/rfc5336.txt
#Code:               X.6.7
#      Sample Text:        The ALT-ADDRESS is required but not specified
#      Associated basic status code:  553, 550
#      Description:        This indicates the reception of a MAIL or RCPT
#                          command that required an ALT-ADDRESS parameter
#                          but such parameter was not present.
#      Defined:            RFC 5336  (Experimental track)
#      Submitter:          Jiankang YAO
#      Change controller:  IESG.
#
#
#      Code:               X.6.8
#      Sample Text:        UTF-8 string reply is required,
#                          but not permitted by the client
#      Associated basic status code:  553, 550
#      Description:        This indicates that a reply containing a UTF-8
#                          string is required to show the mailbox name,
#                          but that form of response is not
#                          permitted by the client.
#      Defined:            RFC  5336.  (Experimental track)
#      Submitter:          Jiankang YAO
#      Change controller:  IESG.
#
#
#       Code:               X.6.9
#       Sample Text:        UTF8SMTP downgrade failed
#       Associated basic status code:  550
#       Description:        This indicates that transaction failed
#                           after the final "." of the DATA command.
#       Defined:            RFC  5336.  (Experimental track)
#       Submitter:          Jiankang YAO
#       Change controller:  IESG.
#
#
#      Code:               X.6.10
#      Sample Text:        UTF-8 string reply is required,
#                          but not permitted by the client
#      Associated basic status code:  252
#      Description:        This indicates that a reply containing a UTF-8
#                          string is required to show the mailbox name,
#                          but that form of response is not
#                          permitted by the client.
#      Defined:            RFC 5336.  (Experimental track)
#      Submitter:          Jiankang YAO
#      Change controller:  IESG.

my $StandardCode = {
    'temporary' => {
        # 'undefined'   => [ '4.0.0' ],
        'hasmoved'      => [ '4.1.6' ],
        'rejected'      => [ '4.1.8' ],
        'mailboxfull'   => [ '4.2.2' ],
        'exceedlimit'   => [ '4.2.3' ],
        'systemfull'    => [ '4.3.1' ],
        'systemerror'   => [ '4.3.5' ],
        'expired'       => [ '4.4.7', '4.4.1' ],
    },
    'permanent' => {
        # 'undefined'   => [ '5.0.0', '5.5.1', '5.5.2', '5.5.3', '5.5.4', '5.5.5' ],
        'userunknown'   => [ '5.1.1', '5.1.0', '5.1.3' ],   # 5.1.3 ?
        'hostunknown'   => [ '5.1.2' ],
        'hasmoved'      => [ '5.1.6' ],
        'rejected'      => [ '5.1.8', '5.1.7' ],
        'filtered'      => [ '5.2.1', '5.2.0' ],
        'mailboxfull'   => [ '5.2.2' ],
        'exceedlimit'   => [ '5.2.3' ],
        'systemfull'    => [ '5.3.1' ],
        'notaccept'     => [ '5.3.2' ],
        'mesgtoobig'    => [ '5.3.4' ],
        'systemerror'   => [ '5.3.5', '5.3.0', '5.4.0', '5.4.1', '5.4.2', '5.4.3', '5.4.4', '5.4.5', '5.4.6',],
        'expired'       => [ '5.4.7' ],
        'mailererror'   => [ '5.2.4' ],
        'contenterror'  => [ '5.6.0' ],
        'securityerror' => [ '5.7.0' ],
        'blocked'       => [ '5.7.1' ],
    },
};

my $InternalCode = {
    'temporary' => {
        'undefined'     => [ '4.0.900' ],
        'hasmoved'      => [ '4.0.916' ],
        'mailboxfull'   => [ '4.0.922' ],
        'exceedlimit'   => [ '4.0.923' ],
        'systemfull'    => [ '4.0.931' ],
        'expired'       => [ '4.0.947' ],
        'suspend'       => [ '4.0.990' ],
    },
    'permanent' => {
        'undefined'     => [ '5.0.900' ],
        'userunknown'   => [ '5.0.911' ],
        'hostunknown'   => [ '5.0.912' ],
        'hasmoved'      => [ '5.0.916' ],
        'rejected'      => [ '5.0.918' ],
        'filtered'      => [ '5.0.921' ],
        'mailboxfull'   => [ '5.0.922' ],
        'exceedlimit'   => [ '5.0.923' ],
        'systemfull'    => [ '5.0.931' ],
        'notaccept'     => [ '5.0.932' ],
        'mesgtoobig'    => [ '5.0.934' ],
        'systemerror'   => [ '5.0.935' ],
        'expired'       => [ '5.0.947' ],
        'contenterr'    => [ '5.0.960' ],
        'securityerr'   => [ '5.0.970' ],
        'blocked'       => [ '5.0.971' ],
        'suspend'       => [ '5.0.990' ],
        'mailererror'   => [ '5.0.991' ],
        'onhold'        => [ '5.0.999' ],
    },
};

sub standardcode { return $StandardCode };
sub internalcode { return $InternalCode };

sub status {
    # @Description  Reason string -> status code
    # @Param <str>  (String) Reason
    # @Param <char> (Character) bounce type; t = temporary or p = permanent(default)
    # @Param <char> (Character) code type; i = internal code or s = standard code(default)
    # @Return       (String) D.S.N.
    #               (String) Empty = Invalid reason name
    my $class = shift;
    my $rname = shift || return '';
    my $btype = shift || 'p';
    my $ctype = shift || 's';
    my $codes = undef;

    $btype = $btype eq 't' ? 'temporary' : 'permanent';
    $codes = $ctype eq 'i' ? $InternalCode : $StandardCode;

    return $codes->{ $btype }->{ $rname }->[0] || '';
}

sub reason {
    # @Description  Status code -> Reason string
    # @Param <str>  (String) Status code(DSN)
    # @Return       (String) Reason name
    #               (String) Empty = Reason does not exist
    my $class = shift;
    my $state = shift || return '';

    return '' unless $state =~ m{\A[45][.]\d[.]\d+\z};

    my $reasonname = '';
    my $softorhard = substr( $state, 0, 1 ) == 4 ? 'temporary' : 'permanent';
    my $mappedcode = substr( $state, 4, 3 ) > 800 
                        ? $InternalCode->{ $softorhard }
                        : $StandardCode->{ $softorhard };

    for my $r ( keys %$mappedcode ) {
        # Search the status code
        next unless grep { $state eq $_ } @{ $mappedcode->{ $r } };
        $reasonname = $r;
        last;
    }
    return $reasonname;
}

sub getdsn {
    # @Description  Get D.S.N. code from given string including D.S.N.
    # @Param <str>  (String) String including D.S.N.
    # @Return       (String) D.S.N.
    #               (String) Empty = There is no D.S.N.
    my $class = shift;
    my $rtext = shift || return '';

    my $deliverysn = '';
    my $regularexp = [
        qr/[ ]?[(][#]([45][.]\d[.]\d+)[)]?[ ]?/,    # #5.5.1
        qr/\b\d{3}[-\s][#]?([45][.]\d[.]\d+)\b/,    # 550-5.1.1 OR 550 5.5.1
        qr/\b([45][.]\d[.]\d+)\b/,                  # 5.5.1
    ];

    for my $e ( @$regularexp ) {
        # Get the value of D.S.N. in the text
        next unless $rtext =~ $e;
        $deliverysn = $1;
        last;
    }
    return $deliverysn;
}

sub is_softbounce {
    # @Description  Softbounce or not
    # @Param <str>  (String) String including SMTP Status code
    # @Return       (Integer) 1 = Soft bounce, 0 = Hard bounce
    #               (Integer) -1 = May not be bounce ?
    my $class = shift;
    my $argvs = shift || return -1;
    my $value = -1;

    if( $argvs =~ m/\b([45])\d\d\b/ ) {
        # 4XX or 5XX
        $value = $1 == 4 ? 1 : 0;
    }
    return $value;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::RFC3463 - D.S.N. related utilities

=head1 SYNOPSIS

    use Sisimai::RFC3463;
    print Sisimai::RFC3463->status('userunknown');             # '5.1.1'
    print Sisimai::RFC3463->reason('5.1.2');                   # 'hostunknown'
    print Sisimai::RFC3463->getdsn('550 5.1.1 Unknown user');  # '5.1.1'

=head1 DESCRIPTION

Sisimai::RFC3463 is utilities for getting D.S.N. value from error reason text,
getting the reason from D.S.N. value, and getting D.S.N. from the text including
D.S.N.

=head1 CLASS METHODS

=head2 C<B<status( I<reason> )>>

C<status()> returns D.S.N. value from the specified reason string.

    print Sisimai::RFC3463->status('mailboxfull');             # '5.2.2'
    print Sisimai::RFC3463->status('mailboxfull','t');         # '4.2.2'

=head2 C<B<reason( I<D.S.N.> )>>

C<reason()> returns a reason string from the specified D.S.N. value.

    print Sisimai::RFC3463->reason('5.1.6');                   # 'hasmoved'
    print Sisimai::RFC3463->reason('4.2.3');                   # 'exceedlimit'

=head2 C<B<getdsn( I<String> )>>

C<getdsn()> returns a D.S.N. value only from the text including D.S.N.

    print Sisimai::RFC3463->getdsn('5.0.0');                   # '5.0.0'
    print Sisimai::RFC3463->getdsn('550 5.1.1 User unknown');  # '5.1.1'

=head2 C<B<is_softbounce( I<String> )>>

C<is_softbounce()> returns 1 if the string includes 4xx SMTP status code.

    print Sisimai::RFC3463->is_softbounce('422 Temporary rejected');    # 1
    print Sisimai::RFC3463->is_softbounce('550 User unknown');          # 0
    print Sisimai::RFC3463->is_softbounce('200 OK');                    # -1 

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
