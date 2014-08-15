package Sisimai::MIME;
use strict;
use warnings;
use Encode;
use MIME::Base64 ();
use MIME::QuotedPrint ();

sub is_mimeencoded {
    # @Description  Check that the argument is MIME-Encoded string or not
    # @Param <str>  (Ref->Scalar) Reference to string
    # @Return       (Integer) 0 = not MIME Encoded, 1 = MIME Encoded string
    my $class = shift;
    my $argvs = shift || return 0;

    return undef unless ref $argvs;
    return undef unless ref $argvs eq 'SCALAR';

    return 1 if $$argvs =~ m{\A[\s\t]*=[?][-_0-9A-Za-z]+[?][BbQq][?].+[?]=\s*\z};
    return 0;
}

sub mimedecode {
    # @Description  Decode MIME-Encoded string
    # @Param <ref>  (Ref->Array) Reference to an array including MIME-Encoded text
    # @Return       (String) MIME-Decoded text
    my $class = shift;
    my $argvs = shift;

    return '' unless ref $argvs;
    return '' unless ref $argvs eq 'ARRAY';

    my $characterset = '';
    my $encodingname = '';
    my $mimeencoded0 = [];
    my $decodedtext0 = [];
    my $decodedtext1 = '';
    my $utf8decoded1 = '';

    for my $e ( @$argvs ) {
        $e =~ s/\A\s+//g;
        $e =~ s/\s+\z//g;

        if( __PACKAGE__->is_mimeencoded( \$e ) ) {
            # MIME Encoded string
            if( $e =~ m{\A=[?]([-_0-9A-Za-z]+)[?]([BbQq])[?](.+)[?]=\z} ) {
                # =?utf-8?B?55m954yr44Gr44KD44KT44GT?=
                $characterset ||= lc $1;
                $encodingname ||= uc $2;
                $mimeencoded0   = $3;

                if( $encodingname eq 'Q' ) {
                    # Quoted-Printable
                    push @$decodedtext0, MIME::QuotedPrint::decode( $mimeencoded0 );

                } elsif( $encodingname eq 'B' ) {
                    # Base64
                    push @$decodedtext0, MIME::Base64::decode( $mimeencoded0 );
                }
            }
        } else {
            push @$decodedtext0, $e;
        }
    }

    return '' unless scalar @$decodedtext0;
    $decodedtext1 = join( '', @$decodedtext0 );

    if( $characterset && $encodingname ) {
        $characterset = 'utf8' if $characterset eq 'utf-8';

        if( $characterset ne 'utf8' ) {
            # Characterset is not UTF-8
            eval {
                Encode::from_to( $decodedtext1, $characterset, 'utf8' );
            };
        }
    }

    $decodedtext1 = 'FAILED TO CONVERT THE SUBJECT' if $@;
    $utf8decoded1 = Encode::decode_utf8 $decodedtext1;
    return $utf8decoded1;
}

sub boundary {
    my $class = shift;
    my $argvs = shift || return undef;
    my $start = shift // -1;
    my $value = '';

    if( $argvs =~ m/\bboundary=([^ ]+)/ ) {
        # Content-Type: multipart/mixed; boundary=Apple-Mail-5--931376066
        # Content-Type: multipart/report; report-type=delivery-status;
	    #    boundary="n6H9lKZh014511.1247824040/mx.example.jp"
        $value =  $1;
        $value =~ y/"'//d;
    }

    $value = sprintf( "--%s", $value ) if $start > -1;
    $value = sprintf( "%s--", $value ) if $start >  0;
    return $value;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::MIME - MIME Utilities

=head1 SYNOPSIS

    use Sisimai::MIME;

    my $e = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';
    my $v = Sisimai::MIME->is_mimeencoded( \$e );
    print $v;   # 1

    my $x = Sisimai::MIME->mimedecode( [ $e ] );
    print $x;

=head1 DESCRIPTION

Sisimai::MIME is MIME Utilities for bouncehammer.

=head1 CLASS METHODS

=head2 C<B<is_mimeencoded( I<Scalar Reference> )>>

C<is_mimeencoded()> returns that the argument is MIME-Encoded string or not.

    my $e = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';
    my $v = Sisimai::MIME->is_mimeencoded( \$e );  # 1

=head2 C<B<mimedecode( I<Array-Ref> )>>

C<mimedecode()> is a decoder method for getting the original string from MIME
Encoded string.

    my $r = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';
    my $v = Sisimai::MIME->mimedecode( [ $r ] );

=head2 C<B<boundary( I<String> )>>

C<boundary()> returns a boundary string from the value of Content-Type header.

    my $r = 'Content-Type: multipart/mixed; boundary=Apple-Mail-1-526612466';
    my $v = Sisimai::MIME->boundary( $r );
    print $v;   # Apple-Mail-1-526612466

    print Sisimai::MIME->boundary( $r, 0 ); # --Apple-Mail-1-526612466
    print Sisimai::MIME->boundary( $r, 1 ); # --Apple-Mail-1-526612466--

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
