package Sisimai::Reason::TooManyConn;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'toomanyconn' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = qr{(?:
         All[ ]available[ ]IPs[ ]are[ ]at[ ]maximum[ ]connection[ ]limit    # SendGrid
        |connection[ ]rate[ ]limit[ ]exceeded
        |no[ ]IPs[ ]available[ ][-][ ].+[ ]exceeds[ ]per[-]domain[ ]connection[ ]limit[ ]for
        |Too[ ]many[ ]connections
        )
    }xi;

    return 1 if $argvs =~ $regex;
    return 0;
}

sub true {
    # @Description  Blocked due to that connection rate limit exceeded
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = too many connections(blocked)
    #               (Integer) 0 = not many connections
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return 1 if $argvs->reason eq __PACKAGE__->text;

    require Sisimai::RFC3463;
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;
    my $tempreason = '';
    my $diagnostic = '';
    my $v = 0;

    $tempreason = Sisimai::RFC3463->reason( $statuscode ) if $statuscode;
    $diagnostic = $argvs->diagnosticcode // '';

    if( $tempreason eq $reasontext ) {
        # Delivery status code points "blocked".
        $v = 1;

    } else {
        # Matched with a pattern in this class
        $v = 1 if __PACKAGE__->match( $diagnostic );
    }
    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::TooManyConn - Bounced due to that too many connections.

=head1 SYNOPSIS

    use Sisimai::Reason::TooManyConn;
    print Sisimai::Reason::TooManyConn->match('Connection rate limit exceeded');    # 1

=head1 DESCRIPTION

Sisimai::Reason::TooManyConn checks the bounce reason is C<toomanyconn> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<toomanyconn>.

    print Sisimai::Reason::TooManyConn->text;  # toomanyconn

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::TooManyConn->match('Connection rate limit exceeded');  # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<toomanyconn>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

