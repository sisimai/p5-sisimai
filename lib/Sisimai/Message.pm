package Sisimai::Message;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::RFC2045;
use Sisimai::RFC5322;
use Sisimai::Address;
use Sisimai::String;
use Sisimai::Order;
use Sisimai::Lhost;

my $ToBeLoaded = [];
my $TryOnFirst = [];
my $ReWrapping = qr<^Content-Type:[ ](?:message/rfc822|text/rfc822-headers)>m; 

sub rise {
    # Constructor of Sisimai::Message
    # @param         [Hash] argvs   Email text data
    # @options argvs [String] data  Entire email message
    # @options argvs [Array]  load  User defined MTA module list
    # @options argvs [Array]  order The order of MTA modules
    # @options argvs [Code]   hook  Reference to callback method
    # @return        [Hash]         Structured email data
    #                [Undef]        If each value of the arguments are missing
    my $class = shift;
    my $argvs = shift            || return undef;
    my $email = $argvs->{'data'} || return undef;
    my $thing = { 'from' => '', 'header' => {}, 'rfc822' => '', 'ds' => [], 'catch' => undef };
    my $param = {};

    # 0. Load specified MTA modules
    for my $e ('load', 'order') {
        # Order of MTA modules
        next unless exists $argvs->{ $e };
        next unless ref $argvs->{ $e } eq 'ARRAY';
        next unless scalar @{ $argvs->{ $e } };
        $param->{ $e } = $argvs->{ $e };
    }
    $ToBeLoaded = __PACKAGE__->load(%$param);

    my $aftersplit = undef;
    my $beforefact = undef;
    my $parseagain = 0;

    while($parseagain < 2) {
        # 1. Split email data to headers and a body part.
        last unless $aftersplit = __PACKAGE__->divideup(\$email);

        # 2. Convert email headers from text to hash reference
        $thing->{'from'}   = $aftersplit->[0];
        $thing->{'header'} = __PACKAGE__->makemap(\$aftersplit->[1]);

        # 3. Decode and rewrite the "Subject:" header
        if( $thing->{'header'}->{'subject'} ) {
            # Decode MIME-Encoded "Subject:" header
            my $s = $thing->{'header'}->{'subject'};
            my $q = Sisimai::RFC2045->is_encoded(\$s) ? Sisimai::RFC2045->decodeH([split(/[ ]/, $s)]) : $s;

            # Remove "Fwd:" string from the "Subject:" header
            if( lc($q) =~ /\A[ \t]*fwd?:[ ]*(.*)\z/ ) {
                # Delete quoted strings, quote symbols(>)
                $q = $1;
                s/^[>]+[ ]//gm, s/^[>]$//gm for $aftersplit->[2];
            }
            $thing->{'header'}->{'subject'} = $q;
        }

        # 4. Rewrite message body for detecting the bounce reason
        $TryOnFirst = Sisimai::Order->make($thing->{'header'}->{'subject'});
        $param = { 'hook' => $argvs->{'hook'} || undef, 'mail' => $thing, 'body' => \$aftersplit->[2] };
        last if $beforefact = __PACKAGE__->parse(%$param);
        last unless $aftersplit->[2] =~ $ReWrapping;

        # 5. Try to parse again
        #    There is a bounce message inside of mutipart/*, try to parse the first message/rfc822
        #    part as a entire message body again.
        $parseagain++;
        $email =  [split($ReWrapping, $aftersplit->[2], 2)]->[-1];
        $email =~ s/\A[\r\n\s]+//m;
        last unless length $email > 128;
    }
    return undef unless $beforefact;

    # 6. Rewrite headers of the original message in the body part
    $thing->{ $_ } = $beforefact->{ $_ } for ('ds', 'catch', 'rfc822');
    my $r = $beforefact->{'rfc822'} || $aftersplit->[2];
    $thing->{'rfc822'} = ref $r ? $r : __PACKAGE__->makemap(\$r, 1);

    return $thing;
}

sub load {
    # Load MTA modules which specified at 'order' and 'load' in the argument
    # @param         [Hash] argvs       Module information to be loaded
    # @options argvs [Array]  load      User defined MTA module list
    # @options argvs [Array]  order     The order of MTA modules
    # @return        [Array]            Module list
    # @since v4.20.0
    my $class = shift;
    my $argvs = { @_ };

    my @modulelist;
    my $tobeloaded = [];

    for my $e ('load', 'order') {
        # The order of MTA modules specified by user
        next unless exists $argvs->{ $e };
        next unless ref $argvs->{ $e } eq 'ARRAY';
        next unless scalar @{ $argvs->{ $e } };

        push @modulelist, @{ $argvs->{'order'} } if $e eq 'order';
        next unless $e eq 'load';

        # Load user defined MTA module
        for my $v ( @{ $argvs->{'load'} } ) {
            # Load user defined MTA module
            eval {
                (my $modulepath = $v) =~ s|::|/|g;
                require $modulepath.'.pm';
            };
            next if $@;
            push @$tobeloaded, $v;
        }
    }

    for my $e ( @modulelist ) {
        # Append the custom order of MTA modules
        next if grep { $e eq $_ } @$tobeloaded;
        push @$tobeloaded, $e;
    }
    return $tobeloaded;
}

sub divideup {
    # Divide email data up headers and a body part.
    # @param         [String] email  Email data
    # @return        [Array]         Email data after split
    # @since v4.14.0
    my $class = shift;
    my $email = shift // return undef;
    my $block = ['', '', ''];   # 0:From, 1:Header, 2:Body

    s/\r\n/\n/gm, s/[ \t]+$//gm for $$email;
    ($block->[1], $block->[2]) = split(/\n\n/, $$email, 2);
    return undef unless $block->[1];
    return undef unless $block->[2];

    if( substr($block->[1], 0, 5) eq 'From ' ) {
        # From MAILER-DAEMON Tue Feb 11 00:00:00 2014
        $block->[0] =  [split(/\n/, $block->[1], 2)]->[0];
        $block->[0] =~ y/\r\n//d;
    } else {
        # Set pseudo UNIX From line
        $block->[0] =  'MAILER-DAEMON Tue Feb 11 00:00:00 2014';
    }

    $block->[1] .= "\n" unless $block->[1] =~ /\n\z/;
    $block->[2] .= "\n";
    return $block;
}

sub makemap {
    # Convert a text including email headers to a hash reference
    # @param    [String] argv0  Email header data
    # @param    [Bool]   argv1  Decode "Subject:" header
    # @return   [Hash]          Structured email header data
    # @since    v4.25.6
    my $class = shift;
    my $argv0 = shift || return {};
    my $argv1 = shift || 0;

    $$argv0 =~ s/^[>]+[ ]//mg;  # Remove '>' indent symbol of forwarded message

    # Select and convert all the headers in $argv0. The following regular expression is based on
    # https://gist.github.com/xtetsuji/b080e1f5551d17242f6415aba8a00239
    my $firstpairs = { $$argv0 =~ /^([\w-]+):[ ]*(.*?)\n(?![\s\t])/gms };
    my $headermaps = { 'subject' => '' };
    my $recvheader = [];

    $headermaps->{ lc $_ } = $firstpairs->{ $_ } for keys %$firstpairs;
    for my $e ( values %$headermaps ) { s/\n\s+/ /, y/\t / /s for $e }

    if( $$argv0 =~ /^Received:/m ) {
        # Capture values of each Received: header
        $recvheader = [$$argv0 =~ /^Received:[ ]*(.*?)\n(?![\s\t])/gms];
        for my $e ( @$recvheader ) { s/\n\s+/ /, y/\n\t / /s for $e }
    }
    $headermaps->{'received'} = $recvheader;

    return $headermaps unless $argv1;
    return $headermaps unless length $headermaps->{'subject'};

    # Convert MIME-Encoded subject
    if( Sisimai::String->is_8bit(\$headermaps->{'subject'}) ) {
        # The value of ``Subject'' header is including multibyte character, is not MIME-Encoded text.
        eval {
            # Remove invalid byte sequence
            Encode::decode_utf8($headermaps->{'subject'});
            Encode::encode_utf8($headermaps->{'subject'});
        };
        $headermaps->{'subject'} = 'MULTIBYTE CHARACTERS HAVE BEEN REMOVED' if $@;

    } else {
        # MIME-Encoded subject field or ASCII characters only
        my $r = [];
        if( Sisimai::RFC2045->is_encoded(\$headermaps->{'subject'}) ) {
            # split the value of Subject by $borderline
            for my $v ( split(/ /, $headermaps->{'subject'}) ) {
                # Insert value to the array if the string is MIME encoded text
                push @$r, $v if Sisimai::RFC2045->is_encoded(\$v);
            }
        } else {
            # Subject line is not MIME encoded
            $r = [$headermaps->{'subject'}];
        }
        $headermaps->{'subject'} = Sisimai::RFC2045->decodeH($r);
    }
    return $headermaps;
}

sub parse {
    # Parse bounce mail with each MTA module
    # @param               [Hash] argvs    Processing message entity.
    # @param options argvs [Hash] mail     Email message entity
    # @param options mail  [String] from   From line of mbox
    # @param options mail  [Hash]   header Email header data
    # @param options mail  [String] rfc822 Original message part
    # @param options mail  [Array]  ds     Delivery status list(parsed data)
    # @param options argvs [String] body   Email message body
    # @param options argvs [Code]   hook   Hook method to be called
    # @return              [Hash]          Parsed and structured bounce mails
    my $class = shift;
    my $argvs = { @_ };

    my $mailheader = $argvs->{'mail'}->{'header'} || return undef;
    my $bodystring = $argvs->{'body'} || return undef;
    my $hookmethod = $argvs->{'hook'} || undef;
    my $havecaught = undef;

    state $defaultset = Sisimai::Order->another;
    state $lhosttable = Sisimai::Lhost->path;

    $mailheader->{'from'}         //= '';
    $mailheader->{'subject'}      //= '';
    $mailheader->{'content-type'} //= '';

    # Decode BASE64 Encoded message body
    my $mesgformat = lc($mailheader->{'content-type'} || '');
    my $ctencoding = lc($mailheader->{'content-transfer-encoding'} || '');
    if( index($mesgformat, 'text/plain') == 0 || index($mesgformat, 'text/html') == 0 ) {
        # Content-Type: text/plain; charset=UTF-8
        if( $ctencoding eq 'base64' ) {
            # Content-Transfer-Encoding: base64
            $bodystring = Sisimai::RFC2045->decodeB($bodystring);

        } elsif( $ctencoding eq 'quoted-printable' ) {
            # Content-Transfer-Encoding: quoted-printable
            $bodystring = Sisimai::RFC2045->decodeQ($bodystring);
        }

        # Content-Type: text/html;...
        $bodystring = Sisimai::String->to_plain($bodystring, 1) if $mesgformat =~ m|text/html;?|;
    } else {
        # NOT text/plain
        if( index($mesgformat, 'multipart/') == 0 ) {
            # In case of Content-Type: multipart/*
            my $p = Sisimai::RFC2045->makeflat($mailheader->{'content-type'}, $bodystring);
            $bodystring = $p if length $$p;
        }
    }
    $$bodystring =~ tr/\r//d;

    if( ref $hookmethod eq 'CODE' ) {
        # Call hook method
        my $p = { 'headers' => $mailheader, 'message' => $$bodystring };
        eval { $havecaught = $hookmethod->($p) };
        warn sprintf(" ***warning: Something is wrong in hook method 'hook': %s", $@) if $@;
    }

    my $haveloaded = {};
    my $parseddata = undef;
    my $modulename = '';
    PARSER: while(1) {
        # 1. User-Defined Module
        # 2. MTA Module Candidates to be tried on first
        # 3. Sisimai::Lhost::*
        # 4. Sisimai::RFC3464
        # 5. Sisimai::ARF
        # 6. Sisimai::RFC3834
        USER_DEFINED: for my $r ( @$ToBeLoaded ) {
            # Call user defined MTA modules
            next if exists $haveloaded->{ $r };
            $parseddata = $r->inquire($mailheader, $bodystring);
            $haveloaded->{ $r } = 1;
            $modulename = $r;
            last(PARSER) if $parseddata;
        }

        TRY_ON_FIRST_AND_DEFAULTS: for my $r ( @$TryOnFirst, @$defaultset ) {
            # Try MTA module candidates
            next if exists $haveloaded->{ $r };
            require $lhosttable->{ $r };
            $parseddata = $r->inquire($mailheader, $bodystring);
            $haveloaded->{ $r } = 1;
            $modulename = $r;
            last(PARSER) if $parseddata;
        }

        unless( $haveloaded->{'Sisimai::RFC3464'} ) {
            # When the all of Sisimai::Lhost::* modules did not return bounce data, call Sisimai::RFC3464;
            require Sisimai::RFC3464;
            $parseddata = Sisimai::RFC3464->inquire($mailheader, $bodystring);
            $modulename = 'RFC3464';
            last(PARSER) if $parseddata;
        }

        unless( $haveloaded->{'Sisimai::ARF'} ) {
            # Feedback Loop message
            require Sisimai::ARF;
            $parseddata = Sisimai::ARF->inquire($mailheader, $bodystring) if Sisimai::ARF->is_arf($mailheader);
            last(PARSER) if $parseddata;
        }

        unless( $haveloaded->{'Sisimai::RFC3834'} ) {
            # Try to parse the message as auto reply message defined in RFC3834
            require Sisimai::RFC3834;
            $parseddata = Sisimai::RFC3834->inquire($mailheader, $bodystring);
            $modulename = 'RFC3834';
            last(PARSER) if $parseddata;
        }
        last; # as of now, we have no sample email for coding this block

    } # End of while(PARSER)
    return undef unless $parseddata;

    $parseddata->{'catch'} = $havecaught;
    $modulename =~ s/\A.+:://;
    $_->{'agent'} ||= $modulename for @{ $parseddata->{'ds'} };
    return $parseddata;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Message - Convert bounce email text to data structure.

=head1 SYNOPSIS

    use Sisimai::Mail;
    use Sisimai::Message;

    my $mailbox = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mailbox->read ) {
        my $p = Sisimai::Message->rise('data' => $r);
    }

    my $notmail = '/home/neko/Maildir/cur/22222';       # is not a bounce email
    my $mailobj = Sisimai::Mail->new($notmail);
    while( my $r = $mailobj->read ) {
        my $p = Sisimai::Message->rise('data' => $r);   # $p is "undef"
    }

=head1 DESCRIPTION

Sisimai::Message convert bounce email text to data structure. It resolve email text into an UNIX From
line, the header part of the mail, delivery status, and RFC822 header part. When the email given as a
argument of "new" method is not a bounce email, the method returns "undef".

=head1 CLASS METHODS

=head2 C<B<rise(I<Hash reference>)>>

C<new()> is a constructor of Sisimai::Message

    my $mailtxt = 'Entire email text';
    my $message = Sisimai::Message->new('data' => $mailtxt);

If you have implemented a custom MTA module and use it, set the value of "load" in the argument of
this method as an array reference like following code:

    my $message = Sisimai::Message->new(
                        'data' => $mailtxt,
                        'load' => ['Your::Custom::MTA::Module']
                  );

Beginning from v4.19.0, `hook` argument is available to callback user defined method like the following
codes:

    my $cmethod = sub {
        my $argv = shift;
        my $data = {
            'queue-id' => '',
            'x-mailer' => '',
            'precedence' => '',
        };

        # Header part of the bounced mail
        for my $e ( 'x-mailer', 'precedence' ) {
            next unless exists $argv->{'headers'}->{ $e };
            $data->{ $e } = $argv->{'headers'}->{ $e };
        }

        # Message body of the bounced email
        if( $argv->{'message'} =~ /^X-Postfix-Queue-ID:\s*(.+)$/m ) {
            $data->{'queue-id'} = $1;
        }

        return $data;
    };

    my $message = Sisimai::Message->new(
        'data' => $mailtxt,
        'hook' => $cmethod,
    );
    print $message->catch->{'x-mailer'};    # Apple Mail (2.1283)
    print $message->catch->{'queue-id'};    # 2DAEB222022E
    print $message->catch->{'precedence'};  # bulk

=head1 INSTANCE METHODS

=head2 C<B<(from)>>

C<from()> returns the UNIX From line of the email.

    print $message->from;

=head2 C<B<header()>>

C<header()> returns the header part of the email.

    print $message->header->{'subject'};    # Returned mail: see transcript for details

=head2 C<B<ds()>>

C<ds()> returns an array reference which include contents of delivery status.

    for my $e ( @{ $message->ds } ) {
        print $e->{'status'};   # 5.1.1
        print $e->{'recipient'};# neko@example.jp
    }

=head2 C<B<rfc822()>>

C<rfc822()> returns a hash reference which include the header part of the original message.

    print $message->rfc822->{'from'};   # cat@example.com
    print $message->rfc822->{'to'};     # neko@example.jp

=head2 C<B<catch()>>

C<catch()> returns any data generated by user-defined method passed at the `hook` argument of new()
constructor.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2022 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
