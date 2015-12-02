package Sisimai::SMTP;
use feature ':5.10';
use strict;
use warnings;

sub command {
    # Detector for SMTP commands in a bounce mail message
    # @private
    # @return   [Hash] SMTP command regular expressions
    return {
        'helo' => qr/\b(?:HELO|EHLO)\b/,
        'mail' => qr/\bMAIL F(?:ROM|rom)\b/,
        'rcpt' => qr/\bRCPT T[Oo]\b/,
        'data' => qr/\bDATA\b/,
    };
}

sub is_softbounce {
    # Check softbounce or not
    # @param    [String] argv1  String including SMTP Status code
    # @return   [Integer]        1: Soft bounce
    #                            0: Hard bounce
    #                           -1: May not be bounce ?
    # @since v4.14.0
    my $class = shift;
    my $argv1 = shift || return -1;

    my $classvalue = -1;
    my $softbounce = -1;

    if( $argv1 =~ m/\b([245])\d\d\b/ ) {
        # SMTP reply code: 550, 421
        $classvalue = $1;

    } elsif( $argv1 =~ m/\b([245])[.][0-9][.]\d+\b/ ) {
        # SMTP DSN: 5.5.1, 4.4.7
        $classvalue = $1;
    }

    if( $classvalue == 4 ) {
        # Soft bounce, Persistent transient error
        $softbounce = 1;

    } elsif( $classvalue == 5 ) {
        # Hard bounce, Permanent error
        $softbounce = 0;

    } else {
        # Check with regular expression
        if( $argv1 =~ m/(?:temporar|persistent)/i ) {
            # Temporary failure
            $softbounce = 1;

        } elsif( $argv1 =~ m/permanent/i ) {
            # Permanently failure
            $softbounce = 0;

        } else {
            # did not find information to decide that it is a soft bounce
            # or a hard bounce.
            $softbounce = -1;
        }
    }

    return $softbounce;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::SMTP - SMTP Status Codes related utilities

=head1 SYNOPSIS

    use Sisimai::SMTP;
    print Sisimai::SMTP->is_softbounce('SMTP error message');

=head1 DESCRIPTION

Sisimai::SMTP is a parent class of Sisimai::SMTP::Status and Sisimai::SMTP::Reply.

=head1 CLASS METHODS

=head2 C<B<is_softbounce(I<String>)>>

C<is_softbounce()> returns 1 if the string includes SMTP reply code like 421,
550 or SMTP status code like 5.1.1, 4.4.7. The return value is 1: softbounce,
0: hard bounce, -1: did not find information to decide that it is a soft bounce
or a hard bounce.

    print Sisimai::SMTP->is_softbounce('422 Temporary rejected');    # 1
    print Sisimai::SMTP->is_softbounce('550 User unknown');          # 0
    print Sisimai::SMTP->is_softbounce('200 OK');                    # -1 
    print Sisimai::SMTP->is_softbounce('4.4.7 Delivery expired');    # 1 
    print Sisimai::SMTP->is_softbounce('Permanent failure');         # 0 

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

