package Sisimai;
use feature ':5.10';
use strict;
use warnings;
use Module::Load '';

our $VERSION = '4.1.26';
sub version { return $VERSION }
sub sysname { 'bouncehammer'  }
sub libname { 'Sisimai'       }

sub make {
    # @Description  Wrapper method for parsing mailbox/maidir
    # @Param <str>  (String) Path to mbox or Maildir/
    # @Return       (Ref->Array) Parsed objects
    #               (undef) Undef if the argument was wrong or an empty array
    my $class = shift;
    my $argvs = shift // return undef;

    require Sisimai::Mail;

    my $mail = Sisimai::Mail->new( $argvs );
    my $mesg = undef;
    my $data = undef;
    my $list = [];

    return undef unless $mail;
    require Sisimai::Data;
    require Sisimai::Message;

    while( my $r = $mail->read ) {
        # Read and parse each mail file
        $mesg = Sisimai::Message->new( 'data' => $r );
        next unless defined $mesg;
        $data = Sisimai::Data->make( 'data' => $mesg );
        push @$list, @$data if scalar @$data;
    }

    return undef unless scalar @$list;
    return $list;
}

sub dump {
    # @Description  Wrapper method to parse mailbox/maidir and dump as JSON
    # @Param <str>  (String) Path to mbox or Maildir/
    # @Return       (Ref->Scalar) JSON text
    my $class = shift;
    my $argv0 = shift // return undef;

    my $parseddata = __PACKAGE__->make( $argv0 ) // [];
    my $jsonobject = undef;
    my $dumpedtext = undef;

    # Dump as JSON
    Module::Load::load( 'JSON', '-convert_blessed_universally' );
    $jsonobject = JSON->new->allow_blessed->convert_blessed;

    return $jsonobject->encode( $parseddata );
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai - Mail Analyzing Interface for bounce mails.

=head1 SYNOPSIS

    use Sisimai;

=head1 DESCRIPTION

Sisimai is the system formerly known as C<bounceHammer> 4, is a Pelr module for
analyzing bounce mails and generate structured data in a JSON format (YAML is 
also available if "YAML" module is installed on your system) from parsed bounce
messages. C<Sisimai> is a coined word: Sisi (the number 4 is pronounced "Si" in
Japanese) and MAI (acronym of "Mail Analyzing Interface").

=head1 BASIC USAGE

=head2 C<B<make( I<'/path/to/mbox'> )>>

C<make> method provides feature for getting parsed data from bounced email 
messages like following.

    use Sisimai;
    my $v = Sisimai->make('/path/to/mbox'); # or Path to Maildir

    if( defined $v ) {
        for my $e ( @$v ) {
            print ref $e;                   # Sisimai::Data
            print ref $e->recipient;        # Sisimai::Address
            print ref $e->timestamp;        # Sisimai::Time

            print $e->addresser->address;   # shironeko@example.org # From
            print $e->recipient->address;   # kijitora@example.jp   # To
            print $e->recipient->host;      # example.jp
            print $e->deliverystatus;       # 5.1.1
            print $e->replycode;            # 550
            print $e->reason;               # userunknown

            my $h = $e->damn;               # Convert to HASH reference
            my $j = $e->dump('json');       # Convert to JSON string
            my $y = $e->dump('yaml');       # Convert to YAML string
        }

        # Dump entire list as a JSON 
        use JSON '-convert_blessed_universally';
        my $json = JSON->new->allow_blessed->convert_blessed;

        printf "%s\n", $json->encode( $v );
    }

=head2 C<B<dump( I<'/path/to/mbox'> )>>
C<dump> method provides feature to get parsed data from bounced email as JSON.

    use Sisimai;
    my $v = Sisimai->dump('/path/to/mbox'); # or Path to Maildir
    print $v;                               # JSON string

=head1 SEE ALSO

=item L<Sisimai::Mail> - Mailbox or Maildir object

=item L<Sisimai::Data> - Parsed data object

=item L<https://tools.ietf.org/html/rfc3463> - RFC3463: Enhanced Mail System Status Codes

=item L<https://tools.ietf.org/html/rfc3464> - RFC3464: An Extensible Message Format for Delivery Status Notifications

=item L<https://tools.ietf.org/html/rfc5321> - RFC5321: Simple Mail Transfer Protocol

=item L<https://tools.ietf.org/html/rfc5322> - RFC5322: Internet Message Format

=head1 REPOSITORY

L<https://github.com/azumakuniyuki/p5-Sisimai> - Sisimai on GitHub

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
