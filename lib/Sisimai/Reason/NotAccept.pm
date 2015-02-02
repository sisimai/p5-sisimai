package Sisimai::Reason::NotAccept;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'notaccept' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = qr!(?:  # Destination mail server does not accept any message
         dns[ ]lookup[ ]failure:[ ].+[ ]try[ ]again[ ]later
        |domain[ ]does[ ]not[ ]exist:
        |greylisted.?.[ ]please[ ]try[ ]again[ ]in
        |http://(?:
             www[.]spamhaus[.]org
            |dsbl[.]org
            |www[.]sorbs[.]net
            )
        |blocked[ ]for[ ]abuse[.][ ]see[ ]http://att[.]net/blocks   # AT&T
        |invalid[ ]domain,[ ]see[ ][<]url:.+[>]
        |ip[ ]\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}[ ]is[ ]blocked[ ]by[ ]earthlink # Earthlink
        |listed[ ]in[ ]work[.]drbl[.]imedia[.]ru
        |mail[ ]server[ ]at[ ].+[ ]is[ ]blocked
        |message[ ]rejected[ ]for[ ]policy[ ]reasons
        |mx[ ]records[ ]for[ ].+[ ]violate[ ]section[ ].+
        |name[ ]service[ ]error[ ]for[ ]    # Malformed MX RR or host not found
        |rfc[ ]1035[ ]violation:[ ]recursive[ ]cname[ ]records[ ]for
        |rule[ ]imposed[ ]as[ ].+is[ ]blacklisted[ ]on              # Mailmarshal RBLs
        |smtp[ ]protocol[ ]returned[ ]a[ ]permanent[ ]error
        |the[ ](?:email|domain|ip).+[ ]is[ ]blacklisted
        |we[ ]do[ ]not[ ]accept[ ]mail[ ]from[ ](?: # @mail.ru
             hosts[ ]with[ ]dynamic[ ]ip[ ]or[ ]generic[ ]dns[ ]ptr-records
            |dynamic[ ]ips
            )
        )
    !xi;

    return 1 if $argvs =~ $regex;
    return 0;
}

sub true { return undef };

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::NotAccept - Bounce reason is C<notaccept> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::NotAccept;
    print Sisimai::Reason::NotAccept->match('domain does not exist:');   # 1

=head1 DESCRIPTION

Sisimai::Reason::NotAccept checks the bounce reason is C<notaccept> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<notaccept>.

    print Sisimai::Reason::NotAccept->text;  # notaccept

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::NotAccept->match('domain does not exist:');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<notaccept>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
