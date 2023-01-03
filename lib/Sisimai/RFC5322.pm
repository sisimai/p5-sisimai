package Sisimai::RFC5322;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC1894;
use constant HEADERTABLE => {
    'messageid' => ['message-id'],
    'subject'   => ['subject'],
    'listid'    => ['list-id'],
    'date'      => [qw|date posted-date posted resent-date|],
    'addresser' => [qw|from return-path reply-to errors-to reverse-path x-postfix-sender envelope-from x-envelope-from|],
    'recipient' => [qw|to delivered-to forward-path envelope-to x-envelope-to resent-to apparently-to|],
};

my $HEADERINDEX = {};
BUILD_FLATTEN_RFC822HEADER_LIST: {
    # Convert $HEADER: hash reference to flatten hash reference for being called from Sisimai::Lhost::*
    for my $v ( values HEADERTABLE()->%* ) {
        $HEADERINDEX->{ $_ } = 1 for @$v;
    }
}

sub FIELDINDEX {
    return [qw|
        Resent-Date From Sender Reply-To To Message-ID Subject Return-Path Received Date X-Mailer
        Content-Type Content-Transfer-Encoding Content-Description Content-Disposition
    |];
    # The following fields are not referred in Sisimai
    #   Resent-From Resent-Sender Resent-Cc Cc Bcc Resent-Bcc In-Reply-To References
    #   Comments Keywords
}

sub HEADERFIELDS {
    # Grouped RFC822 headers
    # @param    [String] group  RFC822 Header group name
    # @return   [Array,Hash]    RFC822 Header list
    my $class = shift;
    my $group = shift || return $HEADERINDEX;
    return HEADERTABLE->{ $group } if exists HEADERTABLE->{ $group };
    return HEADERTABLE;
}

sub LONGFIELDS {
    # Fields that might be long
    # @return   [Hash] Long filed(email header) list
    return { 'to' => 1, 'from' => 1, 'subject' => 1, 'message-id' => 1 };
}

sub received {
    # Convert Received headers to a structured data
    # @param    [String] argv1  Received header
    # @return   [Array]         Received header as a structured data
    my $class = shift;
    my $argv1 = shift || return [];
    my $hosts = [];
    my $value = { 'from' => '', 'by'   => '' };

    # Received: (qmail 10000 invoked by uid 999); 24 Apr 2013 00:00:00 +0900
    return [] if $argv1 =~ /qmail[ \t]+.+invoked[ \t]+/;

    if( $argv1 =~ /\Afrom[ \t]+(.+)[ \t]+by[ \t]+([^ ]+)/ ) {
        # Received: from localhost (localhost) by nijo.example.jp (V8/cf) id s1QB5ma0018057;
        #   Wed, 26 Feb 2014 06:05:48 -0500
        $value->{'from'} = $1;
        $value->{'by'}   = $2;

    } elsif( $argv1 =~ /\bby[ \t]+([^ ]+)(.+)/ ) {
        # Received: by 10.70.22.98 with SMTP id c2mr1838265pdf.3; Fri, 18 Jul 2014
        #   00:31:02 -0700 (PDT)
        $value->{'from'} = $1.$2;
        $value->{'by'}   = $1;
    }

    if( index($value->{'from'}, ' ') > -1 ) {
        # Received: from [10.22.22.222] (smtp.kyoto.ocn.ne.jp [192.0.2.222]) (authenticated bits=0)
        #   by nijo.example.jp (V8/cf) with ESMTP id s1QB5ka0018055; Wed, 26 Feb 2014 06:05:47 -0500
        my @received = split(' ', $value->{'from'});
        my @namelist;
        my @addrlist;
        my $hostname = '';
        my $hostaddr = '';

        for my $e ( @received ) {
            # Received: from [10.22.22.222] (smtp-gateway.kyoto.ocn.ne.jp [192.0.2.222])
            if( $e =~ /\A[(\[]\d+[.]\d+[.]\d+[.]\d+[)\]]\z/ ) {
                # [192.0.2.1] or (192.0.2.1)
                $e =~ y/[]()//d;
                push @addrlist, $e;

            } else {
                # hostname
                $e =~ y/()//d;
                push @namelist, $e;
            }
        }

        for my $e ( @namelist ) {
            # 1. Hostname takes priority over all other IP addresses
            next unless rindex($e, '.') > -1;
            $hostname = $e;
            last;
        }

        unless( $hostname ) {
            # 2. Use IP address as a remote host name
            for my $e ( @addrlist ) {
                # Skip if the address is a private address
                next if index($e, '10.') == 0;
                next if index($e, '127.') == 0;
                next if index($e, '192.168.') == 0;
                next if $e =~ /\A172[.](?:1[6-9]|2[0-9]|3[0-1])[.]/;
                $hostaddr = $e;
                last;
            }
        }
        $value->{'from'} = $hostname || $hostaddr || $addrlist[-1];
    }

    for my $e ('from', 'by') {
        # Copy entries into $hosts
        next unless defined $value->{ $e };
        $value->{ $e } =~ y/()[];?//d;
        push @$hosts, $value->{ $e };
    }
    return $hosts;
}

sub fillet {
    # Split given entire message body into error message lines and the original message part only
    # include email headers
    # @param    [String] mbody  Entire message body
    # @param    [Regexp] regex  Regular expression of the message/rfc822 or the beginning of the
    #                           original message part
    # @return   [Array]         [Error message lines, The original message]
    # @since    v4.25.5
    my $class = shift;
    my $mbody = shift || return undef;
    my $regex = shift || return undef;

    my ($a, $b) = split($regex, $$mbody, 2); $b ||= '';
    if( length $b ) {
        # Remove blank lines, the message body of the original message, and append "\n" at the end
        # of the original message headers
        # 1. Remove leading blank lines
        # 2. Remove text after the first blank line: \n\n
        # 3. Append "\n" at the end of test block when the last character is not "\n"
        $b =~ s/\A[\r\n\s]+//m;
        substr($b, index($b, "\n\n") + 1, length($b), '') if index($b, "\n\n") > 0;
        $b .= "\n" unless $b =~ /\n\z/;
    }
    return [$a, $b];
}

sub tidyup {
    # Tidy up each field name and format
    # @param    [String] argv0 Strings inlcuding field and value used at an email
    # @return   [String]       Strings tidied up
    # @since v5.0.0
    my $class = shift;
    my $argv0 = shift || return '';

    return '' unless $argv0;
    return '' unless length $$argv0;

    state $fields1894 = Sisimai::RFC1894->FIELDINDEX;
    state $fields5322 = __PACKAGE__->FIELDINDEX;
    state @fieldindex = ($fields1894->@*, $fields5322->@*);
    my    $tidiedtext = '';

    for my $e ( split("\n", $$argv0) ) {
        # Find and tidy up fields defined in RFC5322 and RFC1894
        my $fieldlabel = '';    # Field name of this line
        my $substring0 = '';    # Substring picked by substr() from this line

        # 1. Find a field label defined in RFC5322 or RFC1894 from this line
        for my $f ( @fieldindex ) {
            # Find a field name in this line
            next unless index(lc($e), lc($f.':')) == 0;
            $fieldlabel = $f;
            last;
        }

        # 2. Replace the field name with a valid formatted field name
        # 3. Add " " after ":"
        # 4. Remove redundant space characters after ":"
        # 5. Tidy up a sub type of each field defined in RFC1894
        # 6. Remove redundant space characters after ";"
        my $p0 = length $fieldlabel;
        if( $p0 > 0 ) {
            # 2. There is a field label defined in RFC5322 or RFC1894 from this line.
            # Code below replaces the field name with a valid name listed in @fieldindex when the
            # field name does not match with a valid name. For example, Message-ID: and Message-Id:
            $substring0 = substr($e, 0, $p0);
            substr($e, 0, $p0, $fieldlabel) if $substring0 ne $fieldlabel;

            # 3. There is no " " (space character) immediately after ":". For example, To:<cat@...>
            $substring0 = substr($e, $p0 + 1, 1);
            substr($e, $p0, 1, ': ') if $substring0 ne ' ';

            # 4. Remove redundant space characters after ":"
            while(1) {
                # For example, Message-ID:     <...>
                last unless $p0 + 2 < length($e);
                last unless substr($e, $p0 + 2, 1) eq ' ';
                substr($e, $p0 + 2, 1, '');
            }

            # 5. Tidy up a sub type of each field defined in RFC1894 such as Reporting-MTA: DNS;...
            my $p1 = index($e, ';');
            while(1) {
                # Such as Diagnostic-Code, Remote-MTA, and so on
                last unless grep { $fieldlabel eq $_ } (@$fields1894, 'Content-Type');
                last unless $p1 > $p0;

                $substring0 = substr($e, $p0 + 2, $p1 - $p0 - 1);
                substr($e, $p0 + 2, length($substring0), sprintf("%s ", lc $substring0));
                last;
            }

            # 6. Remove redundant space characters after ";"
            while(1) {
                # Such as Diagnostic-Code: SMTP;        user unknown...
                last unless $p1 + 2 < length($e);
                last unless substr($e, $p1 + 2, 1) eq ' ';
                substr($e, $p1 + 2, 1, '');
            }
        }
        $tidiedtext .= $e."\n";
    }

    return  $argv0 unless length $tidiedtext;
    return \$tidiedtext;
}


1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::RFC5322 - Email address related utilities

=head1 SYNOPSIS

    use Sisimai::RFC5322;

=head1 DESCRIPTION

Sisimai::RFC5322 provide methods for checking email address.

=head1 CLASS METHODS

=head2 C<B<received(I<String>)>>

C<received()> returns array reference which include host names in the Received header.

    my $v = 'from mx.example.org (c1.example.net [192.0.2.1]) by mx.example.jp';
    my $r = Sisimai::RFC5322->received($v);

    warn Dumper $r;
    $VAR1 = [
        'mx.example.org',
        'mx.example.jp'
    ];

=head2 C<B<fillet(I<String>, I<RegExp>)>>

C<fillet()> returns array reference which include error message lines of given message body and the
original message part split by the 2nd argument.

    my $v = 'Error message here
    Content-Type: message/rfc822
    Return-Path: <neko@libsisimai.org>';
    my $r = Sisimai::RFC5322->fillet(\$v, qr|^Content-Type:[ ]message/rfc822|m);

    warn Dumper $r;
    $VAR1 = [
        'Error message here',
        'Return-Path: <neko@libsisimai.org>';
    ];

=head2 C<B<tidyup(I<String>, I<String>)>>

C<tidyup()> tidies up each field defined in RFC5322 or RFC1894 in a given string. For example,
"Content-type:     text/plain" will be rewrote to "Content-Type: text/plain".

    my $v = 'Entire email message';
       $v = Sisimai::RFC5322->tidyup(\$v)->$*


=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2023 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
