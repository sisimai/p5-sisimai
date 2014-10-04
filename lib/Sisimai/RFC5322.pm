package Sisimai::RFC5322;
use feature ':5.10';
use strict;
use warnings;

# Regular expression of valid RFC-5322 email address(<addr-spec>)
my $Rx = { 'rfc5322' => undef, 'ignored' => undef, 'domain' => undef, };

BUILD_REGULAR_EXPRESSIONS: {
    # See http://www.ietf.org/rfc/rfc5322.txt
    #  or http://www.ex-parrot.com/pdw/Mail-RFC822-Address.html ...
    #   addr-spec       = local-part "@" domain
    #   local-part      = dot-atom / quoted-string / obs-local-part
    #   domain          = dot-atom / domain-literal / obs-domain
    #   domain-literal  = [CFWS] "[" *([FWS] dcontent) [FWS] "]" [CFWS]
    #   dcontent        = dtext / quoted-pair
    #   dtext           = NO-WS-CTL /     ; Non white space controls
    #                     %d33-90 /       ; The rest of the US-ASCII
    #                     %d94-126        ;  characters not including "[",
    #                                     ;  "]", or "\"
    my $atom           = qr;[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+;o;
    my $quoted_string  = qr/"(?:\\[^\r\n]|[^\\"])*"/o;
    my $domain_literal = qr/\[(?:\\[\x01-\x09\x0B-\x0c\x0e-\x7f]|[\x21-\x5a\x5e-\x7e])*\]/o;
    my $dot_atom       = qr/$atom(?:[.]$atom)*/o;
    my $local_part     = qr/(?:$dot_atom|$quoted_string)/o;
    my $domain         = qr/(?:$dot_atom|$domain_literal)/o;

    $Rx->{'rfc5322'} = qr/$local_part[@]$domain/o;
    $Rx->{'ignored'} = qr/$local_part[.]*[@]$domain/o;
    $Rx->{'domain'}  = qr/$domain/o;
}

sub is_emailaddress {
    # @Description  Check that the argument is an email address or not
    # @Param        (String) Email address
    # @Return       (Integer) 0 = not email address, 1 = email address
    my $class = shift;
    my $email = shift // return 0;

    return 0 if $email =~ m/([\x00-\x1f]|\x1f)/;
    return 1 if $email =~ $Rx->{'ignored'};
    return 0;
}

sub is_domainpart {
    # @Description  Check that the argument is an domain part of email address or not
    # @Param        (String) Domain part of the email address
    # @Return       (Integer) 0 = not domain part, 1 = Valid domain part
    my $class = shift;
    my $dpart = shift // return 0;

    return 0 if $dpart =~ m/([\x00-\x1f]|\x1f)/;
    return 0 if $dpart =~ m/[@]/;
    return 1 if $dpart =~ $Rx->{'domain'};
    return 0;
}

sub is_mailerdaemon {
    # @Description  Check that the argument is mailer-daemon or not
    # @Param        (String) Email address
    # @Return       (Integer) 0 = not mailer-daemon, 1 = mailer-daemon
    my $class = shift;
    my $email = shift // return 0;
    my $rxmds = [
        qr/mailer-daemon[@]/i,
        qr/[<(]mailer-daemon[)>]/i,
        qr/\Amailer-daemon\z/i,
        qr/[ ]?mailer-daemon[ ]/i,
    ];

    return 1 if grep { $email =~ $_ } @$rxmds;
    return 0;
}

sub received {
    # @Description  Convert Received header to structured data
    # @Param <str>  (String) Received header
    # @Return       (Ref->Array) Data
    my $class = shift;
    my $argvs = shift || return [];
    my $hosts = [];
    my $value = {
        'from' => '',
        'by'   => '',
    };

    if( $argvs =~ m/\Afrom\s+(.+)\s+by\s+([^ ]+)/ ) {
        # Received: from localhost (localhost)
        #   by nijo.example.jp (V8/cf) id s1QB5ma0018057;
        #   Wed, 26 Feb 2014 06:05:48 -0500
        $value->{'from'} = $1;
        $value->{'by'}   = $2;

    } elsif( $argvs =~ m/\bby\s+([^ ]+)(.+)/ ) {
        # Received: by 10.70.22.98 with SMTP id c2mr1838265pdf.3; Fri, 18 Jul 2014
        #   00:31:02 -0700 (PDT)
        $value->{'from'} = $1.$2;
        $value->{'by'}   = $1;
    }

    if( $value->{'from'} =~ m/ / ) {
        # Received: from [10.22.22.222] (smtp-gateway.kyoto.ocn.ne.jp [192.0.2.222])
        #   (authenticated bits=0)
        #   by nijo.example.jp (V8/cf) with ESMTP id s1QB5ka0018055;
        #   Wed, 26 Feb 2014 06:05:47 -0500
        my $received = [ split( ' ', $value->{'from'} ) ];
        my $namelist = [];
        my $addrlist = [];
        my $hostname = '';
        my $hostaddr = '';

        for my $e ( @$received ) {
            # Received: from [10.22.22.222] (smtp-gateway.kyoto.ocn.ne.jp [192.0.2.222])
            if( $e =~ m/\A[(\[]\d+[.]\d+[.]\d+[.]\d+[)\]]\z/ ) {
                # [192.0.2.1] or (192.0.2.1)
                $e =~ y/[]()//d;
                push @$addrlist, $e;

            } else {
                # hostname
                $e =~ y/()//d;
                push @$namelist, $e;
            }
        }

        for my $e ( @$namelist ) {
            # 1. Hostname takes priority over all other IP addresses
            next unless $e =~ m/[.]/;
            $hostname = $e;
            last;
        }

        if( length( $hostname ) == 0 ) {
            # 2. Use IP address as a remote host name
            for my $e ( @$addrlist ) {
                # Skip if the address is a private address
                next if $e =~ m/\A(?:10|127)[.]/;
                next if $e =~ m/\A172[.](?:1[6-9]|2[0-9]|3[0-1])[.]/;
                next if $e =~ m/\A192[.]168[.]/;
                $hostaddr = $e;
                last;
            }
        }

        $value->{'from'} = $hostname || $hostaddr || $addrlist->[-1];
    }

    for my $e ( 'from', 'by' ) {
        # Copy entries into $hosts
        next unless defined $value->{ $e };
        $value->{ $e } =~ y/()[];?//d;
        push @$hosts, $value->{ $e };
    }
    return $hosts;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::RFC5322 - Email address related utilities

=head1 SYNOPSIS

    use Sisimai::RFC5322;

    print Sisimai::RFC5322->is_emailaddress('neko@example.jp');    # 1
    print Sisimai::RFC5322->is_domainpart('example.jp');           # 1
    print Sisimai::RFC5322->is_mailerdaemon('neko@example.jp');    # 0

=head1 DESCRIPTION

Sisimai::RFC5322 provide methods for checking email address.

=head1 CLASS METHODS

=head2 C<B<is_emailaddress( I<email address> )>>

C<is_emailaddress()> checks the argument is valid email address or not.

    print Sisimai::RFC5322->is_emailaddress( 'neko@example.jp' );  # 1
    print Sisimai::RFC5322->is_emailaddress( 'neko%example.jp' );  # 0

=head2 C<B<is_domainpart( I<Domain> )>>

C<is_domainpart()> checks the argument is valid domain part of a email address
or not.

    print Sisimai::RFC5322->is_domainpart( 'neko@example.jp' );  # 0
    print Sisimai::RFC5322->is_domainpart( 'neko.example.jp' );  # 1

=head2 C<B<is_domainpart( I<Domain> )>>

C<is_mailerdaemon()> checks the argument is mailer-daemon or not.

    print Sisimai::RFC5322->is_mailerdaemon( 'neko@example.jp' );          # 0
    print Sisimai::RFC5322->is_mailerdaemon( 'mailer-daemon@example.jp' ); # 1

=head2 C<B<received( I<String> )>>

C<received()> returns array reference which include host names in the Received
header.

    my $v = 'from mx.example.org (c1.example.net [192.0.2.1]) by mx.example.jp';
    my $r = Sisimai::RFC5322->received( $v );

    warn Dumper $r; 
    $VAR1 = [
        'mx.example.org',
        'mx.example.jp'
    ];

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
