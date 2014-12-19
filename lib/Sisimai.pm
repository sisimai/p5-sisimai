package Sisimai;
use feature ':5.10';
use strict;
use warnings;

our $VERSION = '4.1.8';
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

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai - It's a core module of bounceHammer version 4

=head1 SYNOPSIS

    use Sisimai;

=head1 DESCRIPTION

Sisimai is a core module of C<bounceHammer> version. 3, is a Perl module for 
analyzing email bounce. C<Sisimai> stands for SISI "Mail Analyzing Interface".

=head1 BASIC USAGE

C<make> method provides feature for getting parsed data from bounced email 
messages like following.

    use Sisimai;
    my $v = Sisimai->make( '/path/to/mbox' );   # or Path to Maildir

    if( defined $v ) {
        for my $e ( @$v ) {
            print ref $e;                   # Sisimai::Data
            print $e->recipient->address;   # kijitora@example.jp
            print $e->reason;               # userunknown

            my $h = $e->damn;               # Convert to HASH reference
            my $j = $e->dump('json');       # Convert to JSON string
        }
    }

=head1 SEE ALSO

L<Sisimai::Mail> - Mailbox or Maildir object
L<Sisimai::Data> - Parsed data object

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
