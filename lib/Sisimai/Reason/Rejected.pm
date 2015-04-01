package Sisimai::Reason::Rejected;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'rejected' }
sub match {
    # Rejected due to envelope from address
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = qr{(?>
         [<][>][ ]invalid[ ]sender
        |address[ ]rejected
        |batv[ ](?:
             failed[ ]to[ ]verify   # SoniWall
            |validation[ ]failure   # SoniWall
            )
        |backscatter[ ]protection[ ]detected[ ]an[ ]invalid[ ]or[ ]expired[ ]email[ ]address    # MDaemon
        |bogus[ ]mail[ ]from        # IMail - block empty sender
        |denied[ ]\[bouncedeny\]    # McAfee
        |domain[ ]of[ ]sender[ ]address[ ].+[ ]does[ ]not[ ]exist
        |empty[ ]envelope[ ]senders[ ]not[ ]allowed
        |error:[ ]no[ ]third-party[ ]dsns               # SpamWall - block empty sender
        |fully[ ]qualified[ ]email[ ]address[ ]required # McAfee
        |recipient[ ]not[ ]accepted[.][ ][(]batv:[ ]no[ ]tag
        |returned[ ]mail[ ]not[ ]accepted[ ]here
        |rule[ ]imposed[ ]mailbox[ ]access[ ]for        # MailMarshal
        |sender[ ](?:
             verify[ ]failed        # Exim callout
            |not[ ]pre[-]approved
            |rejected
            |domain[ ]is[ ]empty
            )
        |syntax[ ]error:[ ]empty[ ]email[ ]address
        |the[ ]message[ ]has[ ]been[ ]rejected[ ]by[ ]batv[ ]defense
        |transaction[ ]failed[ ]unsigned[ ]dsn[ ]for
        )
    }xi;

    return 1 if $argvs =~ $regex;
    return 0;
}

sub true {
    # @Description  Rejected by the envelope sender address or not
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is rejected
    #               (Integer) 0 = is not rejected by the sender
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;

    return undef unless length $statuscode;
    return 1 if $argvs->reason eq $reasontext;

    require Sisimai::RFC3463;
    my $diagnostic = $argvs->diagnosticcode // '';
    my $v = 0;

    if( Sisimai::RFC3463->reason( $statuscode ) eq $reasontext ) {
        # Delivery status code points C<rejected>.
        $v = 1;

    } else {
        # Check the value of Diagnosic-Code: header with patterns
        if( $argvs->smtpcommand eq 'MAIL' ) {
            # Matched with a pattern in this class
            $v = 1 if __PACKAGE__->match( $diagnostic );
        }
    }

    return $v;
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

Sisimai::Reason::Rejected checks the bounce reason is C<rejected> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<rejected>.

    print Sisimai::Reason::Rejected->text;  # rejected

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::Rejected->match('550 Address rejected');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<rejected>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
