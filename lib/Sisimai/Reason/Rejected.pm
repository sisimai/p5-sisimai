package Sisimai::Reason::Rejected;
use v5.26;
use strict;
use warnings;

sub text  { 'rejected' }
sub description { "Email rejected due to a sender's email address (envelope from)" }
sub match {
    # Try to match that the given text and regular expressions
    # @param    [String] argv1  String to be matched with regular expressions
    # @return   [Integer]       0: Did not match
    #                           1: Matched
    # @since v4.0.0
    my $class = shift;
    my $argv1 = shift // return 0;

    state $isnot = [
        "5.1.0 address rejected",
        "ip address ",
        "recipient address rejected",
    ];
    state $index = [
        "access denied (in reply to mail from command)",
        "administrative prohibition",
        "all recipient addresses rejected : access denied",
        "backscatter protection detected an invalid or expired email address", # MDaemon
        "by non-member to a members-only list",
        "can't determine purported responsible address",
        "connections not accepted from servers without a valid sender domain",
        "denied by secumail valid-address-filter", # SecuMail
        "domain of sender address ",
        "email address is on senderfilterconfig list",
        "emetteur invalide",
        "empty email address",
        "empty envelope senders not allowed",
        "from: domain is invalid. please provide a valid from:",
        "fully qualified email address required",   # McAfee
        "invalid sender",
        "is not a registered gateway user",
        "mail from not owned by user",
        "mailfrom domain is listed in spamhaus",
        "null sender is not allowed",
        "returned mail not accepted here",
        "sending this from a different address or alias using the ",
        "sender is spammer",
        "sender not pre-approved",
        "sender domain is empty",
        "sender domain listed at ",
        "sender verify failed",     # Exim callout
        "server does not accept mail from",
        "spam reporting address",   # SendGrid|a message to an address has previously been marked as Spam by the recipient.
        "unroutable sender address",
        "you are not allowed to post to this mailing list",
        "your access to submit messages to this e-mail system has been rejected",
        "your email address has been blacklisted",  # MessageLabs
    ];
    state $pairs = [
        ["after end of data:", ".", " does not exist"],
        ["after mail from:", ".", " does not exist"],
        ["domain ", " is a dead domain"],
        ["email address ", "is not "],
        ["send", "blacklisted"],
        ["sender", " rejected"],
        ["sender is", " list"],
    ];

    return 0 if grep { rindex($argv1, $_) > -1 } @$isnot;
    return 1 if grep { rindex($argv1, $_) > -1 } @$index;
    return 1 if grep { Sisimai::String->aligned(\$argv1, $_) } @$pairs;
    return 0;
}

sub true {
    # Rejected by the envelope sender address or not
    # @param    [Sisimai::Fact] argvs   Object to be detected the reason
    # @return   [Integer]               1: is rejected
    #                                   0: is not rejected by the sender
    # @since v4.0.0
    # @see http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return 0;

    return 1 if $argvs->{'reason'} eq 'rejected';
    my $tempreason = Sisimai::SMTP::Status->name($argvs->{'deliverystatus'}) || 'undefined';
    return 1 if $tempreason eq 'rejected';  # Delivery status code points "rejected".

    # Check the value of Diagnosic-Code: header with patterns
    my $issuedcode = lc $argvs->{'diagnosticcode'};
    my $thecommand = $argvs->{'command'} || '';
    if( $thecommand eq 'MAIL' ) {
        # The session was rejected at 'MAIL FROM' command
        return 1 if __PACKAGE__->match($issuedcode);

    } elsif( $thecommand eq 'DATA' ) {
        # The session was rejected at 'DATA' command
        if( $tempreason ne 'userunknown' ) {
            # Except "userunknown"
            return 1 if __PACKAGE__->match($issuedcode);
        }
    } elsif( $tempreason eq 'onhold' || $tempreason eq 'undefined' ||
             $tempreason eq 'securityerror' || $tempreason eq 'systemerror' ) {
        # Try to match with message patterns when the temporary reason is "onhold", "undefined",
        # "securityerror", or "systemerror"
        return 1 if __PACKAGE__->match($issuedcode);
    }
    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Rejected - Bounce reason is C<rejected> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Rejected;
    print Sisimai::Reason::Rejected->match('550 Address rejected');   # 1

=head1 DESCRIPTION

C<Sisimai::Reason::Rejected> checks the bounce reason is C<rejected> or not. This class is called
only C<Sisimai::Reason> class.

This is the error that the SMTP connection to the destination server was rejected by the sender's
email address (envelope from). Sisimai set C<rejected> to the reason of the email bounce if the value
of C<Status:> field in the  bounce email is C<5.1.8> or the SMTP connection has been rejected due to
the argument of SMTP C<MAIL> command.

    <kijitora@example.org>:
    Connected to 192.0.2.225 but sender was rejected.
    Remote host said: 550 5.7.1 <root@nijo.example.jp>... Access denied

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> method returns the fixed string C<rejected>.

    print Sisimai::Reason::Rejected->text;  # rejected

=head2 C<B<match(I<string>)>>

C<match()> method returns C<1> if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Rejected->match('550 Address rejected');   # 1

=head2 C<B<true(I<Sisimai::Fact>)>>

C<true()> method returns C<1> if the bounce reason is C<rejected>. The argument must be C<Sisimai::Fact>
object and this method is called only from C<Sisimai::Reason> class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019,2021-2026 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

