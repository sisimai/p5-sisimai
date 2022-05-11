package Sisimai::SMTP::Transcript;
use feature ':5.10';
use strict;
use warnings;

sub rise {
    # Parse a transcript of an SMTP session and makes structured data
    # @param    [String] argv0  A transcript text MTA returned
    # @param    [String] argv1  A label string of a SMTP client
    # @param    [String] argv2  A label string of a SMTP server
    # @return   [Array]         Structured data
    # @return   [undef]         Failed to parse or the 1st argument is missing
    # @since v5.0.0
    my $class = shift;
    my $argv0 = shift || return undef;
    my $argv1 = shift || '>>>'; # Label for an SMTP Client
    my $argv2 = shift || '<<<'; # Label for an SMTP Server

    return undef unless ref $argv0 eq 'SCALAR';
    return undef unless length $$argv0;
    return undef unless length $argv1;
    return undef unless length $argv2;

    my $esmtp = [];
    my $table = sub {
        return {
            'command'   => undef,   # SMTP command
            'argument'  => '',      # An argument of each SMTP command sent from a client
            'parameter' => {},      # Parameter pairs of the SMTP command
            'response'  => {        # A Response from an SMTP server
                'reply'  => '',     # - SMTP reply code such as 550
                'status' => '',     # - SMTP status such as 5.1.1
                'text'   => [],     # - Response text lines
            }
        };
    };

    # 1. Replace label strings of SMTP client/server at the each line
    $$argv0 =~ s/^[ ]$argv1\s+/>>> /gm;
    $$argv0 =~ s/^[ ]$argv2\s+/<<< /gm;

    # 2. Remove strings until the first '<<<' or '>>>'
    my $parameters = '';    # Command parameters of MAIL, RCPT
    my $cursession = undef; # Current session for $esmtp

    if( index($$argv0, '<<<') < index($$argv0, '>>>') ) {
        # An SMTP server response starting with '<<<' is the first
        push @$esmtp, $table->();
        $cursession = $esmtp->[-1];
        $cursession->{'command'} = 'CONN';
        $$argv0 =~ s/\A.+?<<</<<</ms;

    } else {
        # An SMTP command starting with '>>>' is the first
        $$argv0 =~ s/\A.+?>>>/>>>/ms;
    }

    # 3. Remove unused lines, concatenate folded lines
    $$argv0 =~ s/\n\n.+\z//ms;      # Remove strings from the first blank line to the tail
    $$argv0 =~ s/\n[\s\t]+/ /g;     # Concatenate folded lines to each previous line

    for my $e ( split("\n", $$argv0) ) {
        # 4. Read each SMTP command and server response
        if( index($e, '>>> ') == 0 ) {
            # SMTP client sent a command ">>> SMTP-command arguments"
            if( $e =~ /\A>>>[ ]([A-Z]+)[ ]?(.*)\z/ ) {
                # >>> SMTP Command
                my $thecommand = $1;
                my $commandarg = $2;

                push @$esmtp, $table->();
                $cursession = $esmtp->[-1];
                $cursession->{'command'} = uc $thecommand;

                if( $thecommand =~ /\A(?:MAIL|RCPT|XFORWARD)/ ) {
                    # MAIL or RCPT
                    if( $commandarg =~ /\A(?:FROM|TO):[ ]*<(.+[@].+)>[ ]*(.*)\z/ ) {
                        # >>> MAIL FROM: <neko@example.com> SIZE=65535
                        # >>> RCPT TO: <kijitora@example.org>
                        $cursession->{'argument'} = $1;
                        $parameters = $2;

                    } else {
                        # >>> XFORWARD NAME=neko2-nyaan3.y.example.co.jp ADDR=230.0.113.2 PORT=53672
                        # <<< 250 2.0.0 Ok
                        # >>> XFORWARD PROTO=SMTP HELO=neko2-nyaan3.y.example.co.jp IDENT=2LYC6642BLzFK3MM SOURCE=REMOTE
                        # <<< 250 2.0.0 Ok
                        $parameters = $commandarg;
                        $commandarg = '';
                    }

                    for my $p ( split(" ", $parameters) ) {
                        # SIZE=22022, PROTO=SMTP, and so on
                        $cursession->{'parameter'}->{ lc $1 } = $2 if $p =~ /\A([^ =]+)=([^ =]+)\z/;
                    }
                } else {
                    # HELO, EHLO, AUTH, DATA, QUIT or Other SMTP command
                    $cursession->{'argument'} = $commandarg;
                }
            }
        } else {
            # SMTP server sent a response "<<< response text"
            next unless index($e, '<<< ') == 0;

            $e =~ s/\A<<<[ ]//;
            $cursession->{'response'}->{'reply'}  = $1 if $e =~ /\A([2-5]\d\d)[ ]/;
            $cursession->{'response'}->{'status'} = $1 if $e =~ /\A[245]\d\d[ ]([245][.]\d{1,3}[.]\d{1,3})[ ]/;
            push(@{ $cursession->{'response'}->{'text'} }, $e);
        }
    }

    return undef unless scalar @$esmtp;
    return $esmtp;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::SMTP::Transcript - Transcript of SMTP session parser

=head1 SYNOPSIS

    use Sisimai::SMTP::Transcript;
    my $v = Sisimai::SMTP::Transcript->rise($transcript, 'In:' 'Out:')

=head1 DESCRIPTION

Sisimai::SMTP::Transcript provides a parser method for converting transcript of SMTP session to a
structured data.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2022 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

