package Sisimai::Reason::UserUnknown;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'userunknown' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        qr/.+ user unknown/,
        qr/[#]5[.]1[.]1 bad address/,
        qr/destination server rejected recipients/,
        qr/email address does not exist/,
        qr/invalid mailbox path/,
        qr/invalid recipient:/,
        qr/no such mailbox/,
        qr/no such recipient/,
        qr/no such user here/,
        qr/no such user/,
        qr/<.+> not found/,
        qr/mailbox not present/,
        qr/mailbox unavailable/,
        qr/no .+ in name directory/,
        qr/recipient address rejected: access denied/,
        qr/recipient address rejected: invalid user/,
        qr/recipient address rejected: user .+ does not exist/,
        qr/recipient address rejected: user unknown in[ ].+[ ]table/,
        qr/recipient address rejected: unknown user/,
        qr/recipient is not local/,
        qr/Requested action not taken: mailbox unavailable/,
        qr/said: 550[-\s]5[.]1[.]1[ ].+[ ]user[ ]unknown[ ]/,
        qr/sorry, user unknown/,
        qr/sorry, no mailbox here by that name/,    # qmail
        qr/this address no longer accepts mail/,
        qr/this user doesn[']?t have a .+ account/, # Yahoo!
        qr/undeliverable address/,
        qr/unknown address/,
        qr/unknown recipient/,
        qr/unknown user/,
        qr/user missing home directory/,
        qr/user unknown/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true {
    # @Description  Whether the address is "userunknown" or not
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is unknown user
    #               (Integer) 0 = is not unknown user.
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;

    return undef unless length $statuscode;
    return 1 if $argvs->reason eq $reasontext;

    require Sisimai::RFC3463;
    my $tempreason = Sisimai::RFC3463->reason( $statuscode );
    return 0 if $tempreason eq 'suspend';

    my $diagnostic = $argvs->diagnosticcode // '';
    my $v = 0;

    if( $tempreason eq $reasontext ) {
        # *.1.1 = 'Bad destination mailbox address'
        #   Status: 5.1.1
        #   Diagnostic-Code: SMTP; 550 5.1.1 <***@example.jp>:
        #     Recipient address rejected: User unknown in local recipient table
        require Module::Load;
        for my $e ( 'RelayingDenied', 'NotAccept' ) {
            # Check the value of "Diagnostic-Code" with other error patterns.
            my $p = 'Sisimai::Reason::'.$e;
            Module::Load::load( $p );
            last if $p->match( $diagnostic );
            $v = 1;
        }
    } else {
        if( $argvs->smtpcommand eq 'RCPT' ) {
            # Check the last SMTP command of the session. When the SMTP command
            # is not "RCPT", the session rejected by other reason, maybe.
            my $s = substr( $statuscode, 0, 1 );
            if( $s == 5 ) {
                # Permanent error, it's a hard bounce.
                $v = 1 if __PACKAGE__->match( $diagnostic );

            } elsif( $s == 4 ) {
                # Temporary error, it's a soft bounce.
                # Postfix Virtual Mail box
                # Status: 4.4.7
                # Diagnostic-Code: SMTP; 450 4.1.1 <***@example.jp>:
                #   Recipient address rejected: User unknown in virtual mailbox table
                $v = 1 if __PACKAGE__->match( $diagnostic );
            }
        }
    }

    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::UserUnknown - Bounce reason is C<userunknown> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::UserUnknown;
    print Sisimai::Reason::UserUnknown->match('550 5.1.1 Unknown User');   # 1

=head1 DESCRIPTION

Sisimai::Reason::UserUnknown checks the bounce reason is C<userunknown> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<userunknown>.

    print Sisimai::Reason::UserUnknown->text;  # userunknown

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::UserUnknown->match('550 5.1.1 Unknown User');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<userunknown>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
