package Sisimai::String;
use feature ':5.10';
use strict;
use warnings;
use Encode;
use Encode::Guess;
use Digest::SHA;

sub EOM {
    # End of email message as a sentinel for parsing bounce messages
    # @private
    # @return   [String] Fixed length string like a constant
    return '__END_OF_EMAIL_MESSAGE__';
}

sub token {
    # Create the message token from an addresser and a recipient
    # @param    [String] addr1  A sender's email address
    # @param    [String] addr2  A recipient's email address
    # @param    [Integer] epoch Machine time of the email bounce
    # @return   [String]        Message token(MD5 hex digest) or empty string 
    #                           if the any argument is missing
    # @see       http://en.wikipedia.org/wiki/ASCII
    # @see       http://search.cpan.org/~gaas/Digest-MD5-2.39/MD5.pm
    my $class = shift || return '';
    my $addr1 = shift || return '';
    my $addr2 = shift || return '';
    my $epoch = shift // return '';

    # Format: STX(0x02) Sender-Address RS(0x1e) Recipient-Address ETX(0x03)
    return Digest::SHA::sha1_hex( 
        sprintf("\x02%s\x1e%s\x1e%d\x03", lc $addr1, lc $addr2, $epoch));
}

sub is_8bit {
    # The argument is 8-bit text or not
    # @param    [String] argv1  Any string to be checked
    # @return   [Integer]       0: ASCII Characters only
    #                           1: Including 8-bit character
    my $class = shift;
    my $argv1 = shift // return undef;

    return undef unless ref $argv1;
    return undef unless ref $argv1 eq 'SCALAR';
    return 1 unless $$argv1 =~ m/\A[\x00-\x7f]+\z/;
    return 0;
}

sub to_utf8 {
    # Convert given string to UTF-8
    # @param    [String] argv1  String to be converted
    # @param    [String] argv2  Encoding name before converting
    # @return   [String]        UTF-8 Encoded string
    my $class = shift;
    my $argv1 = shift || return \'';
    my $argv2 = shift;

    my $tobeutf8ed = $$argv1;
    my $encodefrom = $argv2 || '';
    my $hasencoded = undef;
    my $hasguessed = Encode::Guess->guess($tobeutf8ed);
    my $encodingto = ref $hasguessed ? $hasguessed->name : '';
    my $dontencode = qr/\A(?>utf[-]?8|(?:us[-])?ascii)\z/i;

    if( length $encodefrom ) {
        # The 2nd argument is a encoding name of the 1st argument
        while(1) {
            # Encode a given string when the encoding of the string is neigther
            # utf8 nor ascii.
            last if $encodefrom =~ $dontencode;
            last if $encodingto =~ $dontencode;

            eval { 
                # Try to convert the string to UTF-8
                Encode::from_to($tobeutf8ed, $encodefrom, 'utf8');
                $hasencoded = 1;
            };
            last;
        }
    }

    unless( $hasencoded ) {
        # The 2nd argument was not given or failed to convert from $encodefrom
        # to UTF-8
        if( length $encodingto ) {
            # Guessed encoding name is available, try to encode using it.
            unless( $encodingto =~ $dontencode ) {
                # Encode a given string when the encoding of the string is neigther
                # utf8 nor ascii.
                eval { 
                    Encode::from_to($tobeutf8ed, $encodingto, 'utf8');
                    $hasencoded = 1;
                };
            }
        }
    }
    return \$tobeutf8ed;
}

sub sweep {
    # Clean the string out
    # @param    [String] argv1  String to be cleaned
    # @return   [Scalar]        Cleaned out string
    # @example  Clean up text
    #   sweep('  neko ') #=> 'neko'
    my $class = shift;
    my $argv1 = shift // return undef;

    chomp $argv1;
    $argv1 =~ y{ }{}s;
    $argv1 =~ s{\t}{}g;
    $argv1 =~ s{\A }{}g;
    $argv1 =~ s{ \z}{}g;
    $argv1 =~ s{ [-]{2,}[^ \t].+\z}{};

    return $argv1;
}

sub to_regexp {
    # Convert given string to regular expression
    # @param    [String] argv1  String to be converted to regular expression
    # @return   [Regexp]        Converted regular expression
    my $class = shift;
    my $argv1 = shift;

    return qr/\A\z/ unless length $argv1;
    my $regularexp = undef;
    my $hasescaped = $argv1;
    my $delimiters = ['/', '|', '#', '!', ':', ';', '@'];
    my $delimiter0 = '<';
    my $delimiter1 = '>';

    $hasescaped =~ s/([-^+*.?])/[$1]/g;
    $hasescaped =~ s/\$/\\\$/g;
    for my $e ( @$delimiters ) {
        # Select a delimiter character which is not included in given string
        next if index($argv1, $e) > -1;
        $delimiter0 = $e;
        $delimiter1 = $e;
        last;
    }

    $regularexp = sprintf("qr%s%s%s%s%s", $delimiter0, '\A', $hasescaped, '\z', $delimiter1);
    return eval $regularexp;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::String - String related class

=head1 SYNOPSIS

    use Sisimai::String;
    my $s = 'envelope-sender@example.jp';
    my $r = 'envelope-recipient@example.org';
    my $t = time();

    print Sisimai::String->token($s, $r, $t);  # 2d635de42a44c54b291dda00a93ac27b
    print Sisimai::String->is_8bit(\'猫');     # 1
    print Sisimai::String->sweep(' neko cat ');# 'neko cat'

=head1 DESCRIPTION

Sisimai::String provide utilities for dealing string

=head1 CLASS METHODS

=head2 C<B<token(I<sender>, I<recipient>)>>

C<token()> generates a token: Unique string generated by an envelope sender
address and a envelope recipient address.

    my $s = 'envelope-sender@example.jp';
    my $r = 'envelope-recipient@example.org';

    print Sisimai::String->token($s, $r);    # 2d635de42a44c54b291dda00a93ac27b

=head2 C<B<is_8bit(I<Reference to String>)>>

C<is_8bit()> checks the argument include any 8bit character or not.

    print Sisimai::String->is_8bit(\'cat');  # 0;
    print Sisimai::String->is_8bit(\'ねこ'); # 1;

=head2 C<B<sweep(I<String>)>>

C<sweep()> clean the argument string up: remove trailing spaces, squeeze spaces.

    print Sisimai::String->sweep(' cat neko ');  # 'cat neko';
    print Sisimai::String->sweep(' nyaa   !!');  # 'nyaa !!';

=head2 C<B<to_regexp(I<String>)>>

C<to_regexp> converts from given string to regular expression.

    print Sisimai::String->to_regexp('neko++/nya-n/$cat/meow...?');
    (?^:\Aneko[+][+]/nya[-]n//meow[.][.][.][?]\z)

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2016 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
