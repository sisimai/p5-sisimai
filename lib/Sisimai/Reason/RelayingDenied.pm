package Sisimai::Reason::RelayingDenied;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'norelaying' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/mail server requires authentication when attempting to send to a non-local e-mail address/, # MailEnable 
        qr/relay access denied/,
        qr/relay denied/,
        qr/relay not permitted/,
        qr/relaying denied/,                                    # Sendmail
        qr/that domain isn[']t in my list of allowed rcpthost/, # qmail
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Whether the message is rejected by 'Relaying denied
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = Rejected for "relaying denied"
    #               (Integer) 0 = is not 
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $currreason = $argvs->reason // '';
    my $reasontext = __PACKAGE__->text;

    if( $currreason ) {
        # Do not overwrite the reason
        my $rxnr = qr/\A(?:securityerr|systemerror|undefined)\z/;
        return 0 unless $currreason =~ $rxnr;

    } else {
        # Check the value of Diagnosic-Code: header with patterns
        return 1 if __PACKAGE__->match( $argvs->diagnosticcode );
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::RelayingDenied - Bounce reason is C<norelaying> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::RelayingDenied;
    print Sisimai::Reason::RelayingDenied->match('Relaying denied');   # 1

=head1 DESCRIPTION

Sisimai::Reason::RelayingDenied checks the bounce reason is C<norelaying> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<norelaying>.

    print Sisimai::Reason::RelayingDenied->text;  # norelaying

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::RelayingDenied->match('Relaying denied');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<norelaying>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
