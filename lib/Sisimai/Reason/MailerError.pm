package Sisimai::Reason::MailerError;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'mailererror' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = [
        # postfix/src/global/pipe_command.c:
        #  vstring_prepend(why->reason, "Command failed: ", 
        qr/Command failed: /,

        qr/\Aprocmail: /,                   # procmail
        qr|bin/procmail|,
        qr|bin/maildrop|,
        qr/mailer error/,
        qr/x[-]unix[;][ ]\d{1,3}/,          # X-UNIX; 127
        qr/command died with status \d+/,
        qr/exit \d/,
    ];
    return 1 if grep { lc( $argvs ) =~ $_ } @$regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::MailerError - Bounce reason is C<mailererror> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::MailerError;
    print Sisimai::Reason::MailerError->match('X-Unix; 255');   # 1

=head1 DESCRIPTION

Sisimai::Reason::MailerError checks the bounce reason is C<mailererror> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<mailererror>.

    print Sisimai::Reason::MailerError->text;  # mailererror

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::MailerError->match('X-Unix; 255');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<mailererror>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
