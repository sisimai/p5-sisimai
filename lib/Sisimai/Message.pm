package Sisimai::Message;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load '';
use Sisimai::ARF;
use Sisimai::MIME;
use Sisimai::Order;
use Sisimai::String;
use Sisimai::RFC3834;
use Sisimai::RFC5322;

my $rwaccessors = [
    'from',     # [String] UNIX From line
    'header',   # [Hash]   Header part of a email
    'ds',       # [Array]  Parsed data by Sisimai::MTA::*
    'rfc822',   # [Hash]   Header part of the original message
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );

my $EndOfEmail = Sisimai::String->EOM;
my $DefaultSet = Sisimai::Order->another;
my $PatternSet = Sisimai::Order->by('subject');
my $ExtHeaders = Sisimai::Order->headers;
my $ToBeLoaded = [];
my $TryOnFirst = [];
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;
my @RFC3834Set = ( map { lc $_ } @{ Sisimai::RFC3834->headerlist } );
my @HeaderList = ( 'from', 'to', 'date', 'subject', 'content-type', 'reply-to',
                   'message-id', 'received', 'content-transfer-encoding', 
                   'return-path', 'x-mailer' );
my $MultiHeads = { 'received' => 1 };
my $IgnoreList = { 'dkim-signature' => 1 };
my $Indicators = { 
    'begin' => ( 1 << 1 ),
    'endof' => ( 1 << 2 ),
};

sub new {
    # Constructor of Sisimai::Message
    # @param         [Hash] argvs       Email text data
    # @options argvs [String] data      Entire email message
    # @return        [Sisimai::Message] Structured email data or Undef if each
    #                                   value of the arguments are missing
    my $class = shift;
    my $argvs = { @_ };
    my $email = $argvs->{'data'} // '';
    return undef unless length $email;

    my $methodargv = { 'data' => $email };
    my $messageobj = undef;
    my $parameters = undef;

    for my $e ( 'load', 'order' ) {
        # Order of MTA, MSP modules
        next unless exists $argvs->{ $e };
        next unless ref $argvs->{ $e } eq 'ARRAY';
        next unless scalar @{ $argvs->{ $e } };
        $methodargv->{ $e } = $argvs->{ $e };
    }

    $parameters = __PACKAGE__->make( %$methodargv );
    return undef unless $parameters->{'ds'};

    $messageobj = {
        'from'   => $parameters->{'from'},
        'header' => $parameters->{'header'},
        'ds'     => $parameters->{'ds'},
        'rfc822' => $parameters->{'rfc822'},
    };
    return bless( $messageobj, __PACKAGE__ );
}

sub make {
    # Make data structure from the email message(a body part and headers)
    # @param         [Hash] argvs   Email data
    # @options argvs [String] data  Entire email message
    # @return        [Hash]         Resolved data structure
    my $class = shift;
    my $argvs = { @_ };
    my $email = $argvs->{'data'};

    my $processing = { 'from' => '', 'header' => {}, 'rfc822' => '', 'ds' => [] };
    my @mtamodules = ();

    for my $e ( 'load', 'order' ) {
        # The order of MTA modules specified by user
        next unless exists $argvs->{ $e };
        next unless ref $argvs->{ $e } eq 'ARRAY';
        next unless scalar @{ $argvs->{ $e } };

        push @mtamodules, @{ $argvs->{'order'} } if $e eq 'order';
        next unless $e eq 'load';

        # Load user defined MTA module
        for my $v ( @{ $argvs->{'load'} } ) {
            # Load user defined MTA module
            eval { Module::Load::load $v };
            next if $@;

            for my $w ( @{ $v->headerlist } ) {
                # Get header name which required user defined MTA module
                $ExtHeaders->{ lc $w }->{ $v } = 1;
            }
            push @$ToBeLoaded, $v;
        }
    }

    for my $e ( @mtamodules ) {
        # Append the custom order of MTA modules
        next if grep { $e eq $_ } @$ToBeLoaded;
        push @$ToBeLoaded, $e;
    }

    # 0. Split email data to headers and a body part.
    my $aftersplit = __PACKAGE__->divideup( \$email );
    return undef unless keys %$aftersplit;

    # 1. Initialize variables for setting the value of each email header.
    $TryOnFirst = [];

    # 2. Convert email headers from text to hash reference
    $processing->{'from'}   = $aftersplit->{'from'};
    $processing->{'header'} = __PACKAGE__->headers( \$aftersplit->{'header'} );

    # 3. Check headers for detecting MTA/MSP module
    unless( scalar @$TryOnFirst ) {
        push @$TryOnFirst, @{ __PACKAGE__->makeorder( $processing->{'header'} ) };
    }

    # 4. Rewrite message body for detecting the bounce reason
    my $methodargv = { 'mail' => $processing, 'body' => \$aftersplit->{'body'} };
    my $bouncedata = __PACKAGE__->parse( %$methodargv );

    return undef unless $bouncedata;
    return undef unless keys %$bouncedata;
    $processing->{'ds'} = $bouncedata->{'ds'};

    # 5. Rewrite headers of the original message in the body part
    my $rfc822part = $bouncedata->{'rfc822'} || $aftersplit->{'body'};
    $processing->{'rfc822'} = __PACKAGE__->takeapart( \$rfc822part );

    return $processing;
}

sub divideup {
    # Divide email data up headers and a body part.
    # @param         [String] email  Email data
    # @return        [Hash]          Email data after split
    # @since v4.14.0
    my $class = shift;
    my $email = shift // return {};

    my @hasdivided = undef;
    my $readcursor = 0;
    my $pseudofrom = 'MAILER-DAEMON Tue Feb 11 00:00:00 2014';
    my $aftersplit = { 'from' => '', 'header' => '', 'body' => '' };

    $$email =~ s/[ \t]+$//gm; 
    $$email =~ s/^[ \t]+$//gm;
    @hasdivided = split( "\n", $$email );
    return {} unless scalar @hasdivided;

    if( substr( $hasdivided[0], 0, 5 ) eq 'From ' ) {
        # From MAILER-DAEMON Tue Feb 11 00:00:00 2014
        $aftersplit->{'from'} =  shift @hasdivided;
        $aftersplit->{'from'} =~ y{\r\n}{}d;
    }

    SPLIT_EMAIL: for my $e ( @hasdivided ) {
        # Split email data to headers and a body part.
        $e =~ y/\r\n//d;

        if( $readcursor & $Indicators->{'endof'} ) {
            # The body part of the email
            $aftersplit->{'body'} .= $e."\n";

        } else {
            # The boundary for splitting headers and a body part does not
            # appeare yet.
            if( length $e == 0 ) {
                # Blank line, it is a boundary of headers and a body part
                $readcursor |= $Indicators->{'endof'} if $readcursor & $Indicators->{'begin'};

            } else {
                # The header part of the email
                $aftersplit->{'header'} .= $e."\n";
                $readcursor |= $Indicators->{'begin'};
            }
        }
    }
    return {} unless length $aftersplit->{'header'};
    return {} unless length $aftersplit->{'body'};

    $aftersplit->{'from'} ||= $pseudofrom;
    return $aftersplit;
}

sub headers {
    # Convert email headers from text to hash reference
    # @param         [String] heads  Email header data
    # @return        [Hash]          Structured email header data
    my $class = shift;
    my $heads = shift || return undef;

    my $currheader = '';
    my $allheaders = {};
    my $structured = {};

    map { $allheaders->{ $_ } = 1 } ( @HeaderList, @RFC3834Set, keys %$ExtHeaders );
    map { $structured->{ $_ } = undef } @HeaderList;
    map { $structured->{ lc $_ } = [] } keys %$MultiHeads;

    SPLIT_HEADERS: for my $e ( split( "\n", $$heads ) ) {
        # Convert email headers to hash
        if( $e =~ m/\A([^ ]+?)[:][ ]*(.+?)\z/ ) {
            # split the line into a header name and a header content
            my $lhs = $1;
            my $rhs = $2;

            $currheader = lc $lhs;
            next unless exists $allheaders->{ $currheader };

            if( exists $MultiHeads->{ $currheader } ) {
                # Such as 'Received' header, there are multiple headers in a single
                # email message.
                $rhs =~ y/\t/ /;
                $rhs =~ y/ //s;
                push @{ $structured->{ $currheader } }, $rhs;

            } else {
                # Other headers except "Received" and so on
                if( $ExtHeaders->{ $currheader } ) {
                    # MTA specific header
                    push @$TryOnFirst, keys %{ $ExtHeaders->{ $currheader } };
                }
                $structured->{ $currheader } = $rhs;
            }

        } elsif( $e =~ m/\A[ \t]+(.+?)\z/ ) {
            # Ignore header?
            next if exists $IgnoreList->{ $currheader };

            # Header line continued from the previous line
            if( ref $structured->{ $currheader } eq 'ARRAY' ) {
                # Concatenate a header which have multi-lines such as 'Received'
                $structured->{ $currheader }->[ -1 ] .= ' '.$1;

            } else {
                $structured->{ $currheader } .= ' '.$1;
            }
        }
    }
    return $structured;
}

sub makeorder {
    # Check headers for detecting MTA/MSP module and returns the order of modules
    # @param         [Hash] heads   Email header data
    # @return        [Array]        Order of MTA/MSP modules
    my $class = shift;
    my $heads = shift || return [];
    my $order = [];

    return [] unless length $heads->{'subject'};

    # Try to match the value of "Subject" with patterns generated by
    # Sisimai::Order->by('subject') method
    for my $e ( keys %$PatternSet ) {
        # Get MTA list from the subject header
        next unless $heads->{'subject'} =~ $e;

        # Matched and push MTA list
        push @$order, @{ $PatternSet->{ $e } };
        last;
    }
    return $order;
}

sub takeapart {
    # Take each email header in the original message apart
    # @param         [String] heads The original message header
    # @return        [Hash]         Structured message headers
    my $class = shift;
    my $heads = shift || return {};

    # Convert from string to hash reference
    $$heads =~ s/^[>]+[ ]//mg;

    my $takenapart = {};
    my @hasdivided = split( "\n", $$heads );
    my $previousfn = ''; # Previous field name
    my $borderline = '__MIME_ENCODED_BOUNDARY__';
    my $mimeborder = {};

    for my $e ( @hasdivided ) {
        # Header name as a key, The value of header as a value
        if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
            # Header
            my $lhs = lc $1;
            my $rhs = $2;

            $previousfn = '';

            next unless exists $RFC822Head->{ $lhs };
            $previousfn = $lhs;
            $takenapart->{ $previousfn } //= $rhs;

        } else {
            # Continued line from the previous line
            next unless $e =~ m/\A[ \t]+/;
            next unless $previousfn;

            # Concatenate the line if it is the value of required header
            if( Sisimai::MIME->is_mimeencoded( \$e ) ) {
                # The line is MIME-Encoded test
                if( $previousfn eq 'subject' ) {
                    # Subject: header
                    $takenapart->{ $previousfn } .= $borderline.$e;

                } else {
                    # Is not Subject header
                    $takenapart->{ $previousfn } .= $e;
                }
                $mimeborder->{ $previousfn } = 1;

            } else {
                # ASCII Characters only: Not MIME-Encoded
                $takenapart->{ $previousfn }  .= $e;
                $mimeborder->{ $previousfn } //= 0;
            }
        }
    }

    if( $takenapart->{'subject'} ) {
        # Convert MIME-Encoded subject
        my $v = $takenapart->{'subject'};

        if( Sisimai::String->is_8bit( \$v ) ) {
            # The value of ``Subject'' header is including multibyte character,
            # is not MIME-Encoded text.
            $v = 'MULTIBYTE CHARACTERS HAVE BEEN REMOVED';

        } else {
            # MIME-Encoded subject field or ASCII characters only
            my $r = [];

            if( $mimeborder->{'subject'} ) {
                # split the value of Subject by $borderline
                for my $m ( split( $borderline, $v ) ) {
                    # Insert value to the array if the string is MIME
                    # encoded text
                    push @$r, $m if Sisimai::MIME->is_mimeencoded( \$m );
                }
            } else {
                # Subject line is not MIME encoded
                $r = [ $v ];
            }
            $v = Sisimai::MIME->mimedecode( $r );
        }
        $takenapart->{'subject'} = $v;
    } 
    return $takenapart;
}

sub parse {
    # Parse bounce mail with each MTA/MSP module
    # @param               [Hash] argvs    Processing message entity.
    # @param options argvs [Hash] mail     Email message entity
    # @param options mail  [String] from   From line of mbox
    # @param options mail  [Hash]   header Email header data
    # @param options mail  [String] rfc822 Original message part
    # @param options mail  [Array]  ds     Delivery status list(parsed data)
    # @param options argvs [String] body   Email message body
    # @param options argvs [Array] load    MTA/MSP module list to load on first
    # @return              [Hash]          Parsed and structured bounce mails
    my $class = shift;
    my $argvs = { @_ };

    my $mesgentity = $argvs->{'mail'} || return '';
    my $bodystring = $argvs->{'body'} || return '';
    my $mailheader = $mesgentity->{'header'};

    # PRECHECK_EACH_HEADER:
    # Set empty string if the value is undefined
    $mailheader->{'from'}         //= '';
    $mailheader->{'subject'}      //= '';
    $mailheader->{'content-type'} //= '';

    # Decode BASE64 Encoded message body
    my $mesgformat = lc( $mailheader->{'content-type'} || '' );
    my $ctencoding = lc( $mailheader->{'content-transfer-encoding'} || '' );

    if( $mesgformat =~ m|text/plain;| ) {
        # Content-Type: text/plain; charset=UTF-8
        if( $ctencoding eq 'base64' || $ctencoding eq 'quoted-printable' ) {
            # Content-Transfer-Encoding: base64
            # Content-Transfer-Encoding: quoted-printable
            if( $ctencoding eq 'base64' ) {
                # Content-Transfer-Encoding: base64
                $$bodystring = Sisimai::MIME->base64d( $bodystring );

            } else {
                # Content-Transfer-Encoding: quoted-printable
                $$bodystring = Sisimai::MIME->qprintd( $bodystring );
            }
        }
    }

    # EXPAND_FORWARDED_MESSAGE:
    # Check whether or not the message is a bounce mail.
    # Pre-Process email body if it is a forwarded bounce message.
    # Get the original text when the subject begins from 'fwd:' or 'fw:'
    if( $mailheader->{'subject'} =~ m/\A[ \t]*fwd?:/i ) {
        # Delete quoted strings, quote symbols(>)
        $$bodystring =~ s/^[>]+[ ]//gm;
        $$bodystring =~ s/^[>]$//gm;
    }
    $$bodystring .= $EndOfEmail;

    my $haveloaded = {};
    my $scannedset = undef;

    SCANNER: while(1) {
        # 1. Sisimai::ARF 
        # 2. User-Defined Module
        # 3. MTA Module Candidates to be tried on first
        # 4. Sisimai::MTA::* and MSP::*
        # 5. Sisimai::RFC3464
        # 6. Sisimai::RFC3834
        #
        if( Sisimai::ARF->is_arf( $mailheader ) ) {
            # Feedback Loop message
            $scannedset = Sisimai::ARF->scan( $mailheader, $bodystring );
            last(SCANNER) if $scannedset;
        }

        USER_DEFINED: for my $r ( @$ToBeLoaded ) {
            # Call user defined MTA modules
            next if exists $haveloaded->{ $r };
            $scannedset = $r->scan( $mailheader, $bodystring );
            $haveloaded->{ $r } = 1;
            last(SCANNER) if $scannedset;
        }

        TRY_ON_FIRST: while( my $r = shift @$TryOnFirst ) {
            # Try MTA module candidates which are detected from MTA specific
            # mail headers on first
            next if exists $haveloaded->{ $r };
            $scannedset = $r->scan( $mailheader, $bodystring );
            $haveloaded->{ $r } = 1;
            last(SCANNER) if $scannedset;
        }

        DEFAULT_LIST: for my $r ( @$DefaultSet ) {
            # MTA/MSP modules which does not have MTA specific header and did
            # not match with any regular expressions of Subject header.
            next if exists $haveloaded->{ $r };
            $scannedset = $r->scan( $mailheader, $bodystring );
            $haveloaded->{ $r } = 1;
            last(SCANNER) if $scannedset;
        }

        # When the all of Sisimai::MTA::* modules did not return bounce data,
        # call Sisimai::RFC3464;
        require Sisimai::RFC3464;
        $scannedset = Sisimai::RFC3464->scan( $mailheader, $bodystring );
        last(SCANNER) if $scannedset;

        # Try to parse the message as auto reply message defined in RFC3834
        require Sisimai::RFC3834;
        $scannedset = Sisimai::RFC3834->scan( $mailheader, $bodystring );
        last(SCANNER) if $scannedset;

        # as of now, we have no sample email for coding this block
        last;

    } # End of while(SCANNER)
    return $scannedset;
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
        my $p = Sisimai::Message->new( 'data' => $r );
    }

    my $notmail = '/home/neko/Maildir/cur/22222';   # is not a bounce email
    my $mailobj = Sisimai::Mail->new( $notmail );
    while( my $r = $mailobj->read ) {
        my $p = Sisimai::Message->new( 'data' => $r );  # $p is "undef"
    }

=head1 DESCRIPTION

Sisimai::Message convert bounce email text to data structure. It resolve email
text into an UNIX From line, the header part of the mail, delivery status, and
RFC822 header part. When the email given as a argument of "new" method is not a
bounce email, the method returns "undef".

=head1 CLASS METHODS

=head2 C<B<new( I<Hash reference> )>>

C<new()> is a constructor of Sisimai::Message

    my $mailtxt = 'Entire email text';
    my $message = Sisimai::Message->new( 'data' => $mailtxt );

If you have implemented a custom MTA module and use it, set the value of "load"
in the argument of this method as an array reference like following code:

    my $message = Sisimai::Message->new( 
                        'data' => $mailtxt,
                        'load' => [ 'Your::Custom::MTA::Module' ]
                  );

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

C<rfc822()> returns a hash reference which include the header part of the original
message.

    print $message->rfc822->{'from'};   # cat@example.com
    print $message->rfc822->{'to'};     # neko@example.jp

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
