package Sisimai::RFC5322;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::String;
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
    return [] if index($argv1, '(qmail ') > 0 && index($argv1, ' invoked ') > 0;

    my $p1 = index($argv1, 'from ');
    my $p2 = index($argv1, 'by ');
    my $p3 = index($argv1, ' ', $p2 + 3);

    if( $p1 == 0 && $p2 > 1 && $p2 < $p3 ) {
        # Received: from localhost (localhost) by nijo.example.jp (V8/cf) id s1QB5ma0018057;
        #   Wed, 26 Feb 2014 06:05:48 -0500
        $value->{'from'} = Sisimai::String->sweep(substr($argv1, $p1 + 5, $p2 - $p1 - 5));
        $value->{'by'}   = Sisimai::String->sweep(substr($argv1, $p2 + 3, $p3 - $p2 - 3)); 

    } elsif( $p1 != 0 && $p2 > -1 ) {
        # Received: by 10.70.22.98 with SMTP id c2mr1838265pdf.3; Fri, 18 Jul 2014
        #   00:31:02 -0700 (PDT)
        $value->{'from'} = Sisimai::String->sweep(substr($argv1, $p2 + 3,));
        $value->{'by'}   = Sisimai::String->sweep(substr($argv1, $p2 + 3, $p3 - $p2 - 3));
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
            my $cv = Sisimai::String->ipv4($e) || [];
            if( scalar @$cv > 0 ) {
                # [192.0.2.1] or (192.0.2.1)
                push @addrlist, @$cv;

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

sub part {
    # Split given entire message body into error message lines and the original message part only
    # include email headers
    # @param    [String] email  Entire message body
    # @param    [Array]  cutby  List of strings which is a boundary of the original message part
    # @param    [Bool]   keeps  Flag for keeping strings after "\n\n"
    # @return   [Array]         [Error message lines, The original message]
    # @since    v5.0.0
    my $class = shift;
    my $email = shift || return undef;
    my $cutby = shift || return undef;
    my $keeps = shift // 0;

    my $boundaryor = '';    # A boundary string divides the error message part and the original message part
    my $positionor = -1;    # A Position of the boundary string
    my $formerpart = '';    # The error message part
    my $latterpart = '';    # The original message part

    for my $e ( @$cutby ) {
        # Find a boundary string(2nd argument) from the 1st argument
        $positionor = index($$email, $e); next if $positionor == -1;
        $boundaryor = $e;
        last;
    }

    if( $positionor > 0 ) {
        # There is the boundary string in the message body
        $formerpart = substr($$email, 0, $positionor);
        $latterpart = substr($$email, ($positionor + length($boundaryor) + 1), ) || '';

    } else {
        # Substitute the entire message to the former part when the boundary string is not included
        # the $$email
        $formerpart = $$email;
        $latterpart = '';
    } 

    if( length $latterpart > 0 ) {
        # Remove blank lines, the message body of the original message, and append "\n" at the end
        # of the original message headers
        # 1. Remove leading blank lines
        # 2. Remove text after the first blank line: \n\n
        # 3. Append "\n" at the end of test block when the last character is not "\n"
        $latterpart =~ s/\A[\r\n\s]+//m;
        if( $keeps == 0 ) {
            # Remove text after the first blank line: \n\n when $keeps is 0
            substr($latterpart, index($latterpart, "\n\n") + 1, length($latterpart), '') if index($latterpart, "\n\n");
        }
        $latterpart .= "\n" unless substr($latterpart, -1, 1) eq "\n";
    }
    return [$formerpart, $latterpart];
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

=head2 C<B<part(I<String>, I<Array>)>>

C<part()> returns array reference which include error message lines of given message body and the
original message part split by the 2nd argument.

    my $v = 'Error message here
    Content-Type: message/rfc822
    Return-Path: <neko@libsisimai.org>';
    my $r = Sisimai::RFC5322->part(\$v, ['Content-Type: message/rfc822']);

    warn Dumper $r;
    $VAR1 = [
        'Error message here',
        'Return-Path: <neko@libsisimai.org>';
    ];

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2023 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
