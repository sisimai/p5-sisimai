package Sisimai::Reason::Filtered;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'filtered' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/because the recipient is only accepting mail from specific email addresses/, # AOL Phoenix
        qr/due to extended inactivity new mail is not currently being accepted for this mailbox/,
        qr|http://postmaster[.]facebook[.]com/.+refused due to recipient preferences|,  # Facebook
        qr/permanent failure for one or more recipients [(].+:blocked[)]/,
        qr/user not found:/,    # Filter on MAIL.RU
        qr/user reject/,
        qr/we failed to deliver mail because the following address recipient id refuse to receive mail/,    # Willcom
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Rejected by domain or address filter ?
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is filtered
    #               (Integer) 0 = is not filtered
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return 1 if $argvs->reason eq __PACKAGE__->text;

    require Sisimai::RFC3463;
    my $statuscode = $argvs->deliverystatus // '';
    my $commandtxt = $argvs->smtpcommand // '';
    my $reasontext = __PACKAGE__->text;
    my $tempreason = '';
    my $diagnostic = '';
    my $v = 0;

    $diagnostic = $argvs->diagnosticcode // '';
    $tempreason = Sisimai::RFC3463->reason( $statuscode );
    return 0 if $tempreason eq 'suspend';

    if( $tempreason eq $reasontext ) {
        # Delivery status code points "filtered".
        $v = 1;

    } else {
        # Check the value of Diagnostic-Code and the last SMTP command
        my $c = $argvs->smtpcommand;
        if( $c ne 'RCPT' && $c ne 'MAIL' ) {
            # Check the last SMTP command of the session. 
            if( __PACKAGE__->match( $diagnostic ) ) {
                # Matched with a pattern in this class
                $v = 1;

            } else {
                # Did not match with patterns in this class,
                # Check the value of "Diagnostic-Code" with other error patterns.
                require Sisimai::Reason::UserUnknown;
                $v = 1 if Sisimai::Reason::UserUnknown->match( $diagnostic );
            }
        }
    }

    return $v;
}


1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Filtered - Bounce reason is C<filtered> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::Filtered;
    print Sisimai::Reason::Filtered->match('550 5.1.2 User reject');   # 1

=head1 DESCRIPTION

Sisimai::Reason::Filtered checks the bounce reason is C<filtered> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<filtered>.

    print Sisimai::Reason::Filtered->text;  # filtered

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Filtered->match('550 5.1.2 User reject');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<filtered>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
