package Sisimai::Reason::SecurityError;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'securityerror' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/authentication failed; server .+ said:/,     # Postfix
        qr/authentication turned on in your email client/,

        # Rejected due to message contents: spam, virus or header.
        qr/\d+ denied \[[a-z]+\] .+[(]Mode: .+[)]/,
        qr/because the recipient is not accepting mail with attachments/,   # AOL Phoenix
        qr/because the recipient is not accepting mail with embedded images/,   # AOL Phoenix
        qr/blocked by policy: no spam please/,
        qr/blocked by spamAssassin/,        # rejected by SpamAssassin
        qr/domain .+ is a dead domain/,
        qr/email not accepted for policy reasons/,

        qr/mail appears to be unsolicited/, # rejected due to spam
        qr/message filtered/,
        qr/message filtered[.] please see the faqs section on spam/,
        qr/message rejected due to suspected spam content/,

        qr/message refused by mailmarshal spamprofiler/,
        qr/our filters rate at and above .+ percent probability of being spam/,
        qr/rejected: spamassassin score /,
        qr/rejected due to spam content/,
        qr/sorry, that domain isn'?t in my list of allowed rcpthosts/,
        qr/sorry, your don'?t authenticate or the domain isn'?t in my list of allowed rcpthosts/,
        qr/spam not accepted/,
        qr/spambouncer identified spam/,    # SpamBouncer identified SPAM

        qr/the message was rejected because it contains prohibited virus or spam content/,
        qr/we dont accept spam/,
        qr/your message has been temporarily blocked by our filter/,
        qr/your network is temporary blacklisted/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::SecurityError - Bounce reason is C<securityerror> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::SecurityError;
    print Sisimai::Reason::SecurityError->match('5.7.1 Email not accept');   # 1

=head1 DESCRIPTION

Sisimai::Reason::SecurityError checks the bounce reason is C<securityerror> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<securityerror>.

    print Sisimai::Reason::SecurityError->text;  # securityerror

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::SecurityError->match('5.7.1 Email not accept');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<securityerror>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
