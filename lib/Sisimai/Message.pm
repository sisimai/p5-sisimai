package Sisimai::Message;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load;
use Sisimai::ARF;
use Try::Tiny;

my $rwaccessors = [
    'from',             # (String) UNIX From line
    'header',           # (Ref->Hash) Header part of a email
    'ds',               # (Ref->Array) Parsed data by Sisimai::MTA::*
    'rfc822',           # (String) Header part of the original message
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );

my $DefaultMTA = [
    'Sendmail',
    'Postfix',
    'qmail',
    'OpenSMTPD',
    'Exim',
    'Courier',
    'Exchange',
    'Domino',
];

my $DefaultMSP = [
    'US::Google',
    'US::Verizon',
    'US::Facebook',
    'JP::KDDI',
    'JP::Biglobe',
    'US::AmazonSES',
    'US::SendGrid',
];

sub ENDOFEMAIL { '__END_OF_EMAIL_MESSAGE__' };

sub new {
    # @Description  Constructor of Sisimai::Message
    # @Param <str>  (String) Email text
    # @Return       (Sisimai::Message) Structured email data
    my $class = shift;
    my $argvs = { @_ };
    my $email = $argvs->{'data'} // q();
    return undef unless length $email;

    my $methodargv = { 'data' => $email };
    my $messageobj = undef;
    my $parameters = undef;

    if( ref $argvs->{'mtalist'} eq 'ARRAY' ) {
        $methodargv->{'mtalist'} = $argvs->{'mtalist'};
    }

    $parameters = __PACKAGE__->resolve( %$methodargv );
    return undef unless $parameters->{'ds'};

    $messageobj = {
        'from'   => $parameters->{'from'},
        'header' => $parameters->{'header'},
        'ds'     => $parameters->{'ds'},
        'rfc822' => $parameters->{'rfc822'},
    };

    return bless( $messageobj, __PACKAGE__ );
}

sub resolve {
    # @Description  Resolve the email message into data structure(body,header)
    # @Param <ref>  (Ref->Hash) email text in "data" key
    # @Return       (Ref->Hash) Resolved data structure
    my $class = shift;
    my $argvs = { @_ };
    my $email = $argvs->{'data'};

    my $processing = { 'from' => '', 'header' => {}, 'rfc822' => '', 'ds' => [] };
    my $methodargv = {};
    my $mtamodules = [];
    my $mspmodules = [];

    if( ref $argvs->{'mtalist'} eq 'ARRAY' && scalar @{ $argvs->{'mtalist'} } ) {
        # The order of MTA modules specified by user
        push @$mtamodules, @{ $argvs->{'mtalist'} };
        push @$mspmodules, @{ $argvs->{'msplist'} };
    }

    # Default order of MTA modules
    push @$mtamodules, @$DefaultMTA;
    push @$mspmodules, @$DefaultMSP;

    EMAIL_PROCESSING: {
        my $endofheads = 0;
        my $first5byte = '';
        my $mailheader = '';
        my $bodystring = '';
        my $bouncedata = undef;
        my $rfc822part = undef;

        # 0. Split email data to headers and a body part.
        SPLIT_EMAIL: for my $e ( split( "\n", $email ) ) {
            # use split() instead of regular expression.
            $e =~ y{\r\n}{}d;
            $first5byte ||= $e if $e =~ m/\AFrom[ ]/;

            if( $endofheads ) {
                # The body part of the email
                $bodystring .= $e."\n";

            } else {
                # The boundary for splitting headers and a body part does not
                # appeare yet.
                if( length $e == 0 ) {
                    # Blank line, it is a boundary of headers and a body part
                    $endofheads = 1;

                } else {
                    # The header part of the email
                    $mailheader .= $e."\n";
                }
            }
        }

        return undef unless length $mailheader;
        return undef unless length $bodystring;

        # 1. Initialize $processing variable for setting the value of each email header.
        $processing->{'from'} = $first5byte || 'MAILER-DAEMON Tue Feb 11 00:00:00 2014';
        $processing->{'header'} = {};

        CONVERT_HEADER: {
            # 2. Convert email headers from text to hash reference
            my $mtaclasses = [ map { 'Sisimai::MTA::'.$_ } @$mtamodules ];
            my $mspclasses = [ map { 'Sisimai::MSP::'.$_ } @$mspmodules ];
            my $currheader = '';
            my $headerlist = [ 
                'From', 'To', 'Date', 'Subject', 'Content-Type', 'Reply-To',
                'Message-Id', 'Received'
            ];
            my $multiheads = [ 'Received' ];
            my $ignorelist = [ 'DKIM-Signature' ];

            map { $processing->{'header'}->{ lc $_ } = undef } @$headerlist;
            map { $processing->{'header'}->{ lc $_ } = [] } @$multiheads;

            MTA_MODULES: for my $e ( @$mtaclasses ) {
                # Load MTA modules saved in lib/Sisimai/MTA directory
                try {
                    Module::Load::load $e;
                    for my $v ( @{ $e->headerlist } ) {
                        # Get header name which required each MTA module
                        next if grep { $v eq $_ } @$headerlist;
                        push @$headerlist, $v;
                    }
                } catch {
                    # Perhaps it failed to load Sisimai::MTA::*
                    ;
                };
            }

            MSP_MODULES: for my $e ( @$mspclasses ) {
                # Load MSP modules saved in lib/Sisimai/MSP directory
                try {
                    Module::Load::load $e;
                    for my $v ( @{ $e->headerlist } ) {
                        # Get header name which required each MSP module
                        next if grep { $v eq $_ } @$headerlist;
                        push @$headerlist, $v;
                    }
                } catch {
                    # Perhaps it failed to load Sisimai::MSP::*
                    ;
                };
            }

            SPLIT_HEADERS: for my $e ( split( "\n", $mailheader ) ) {

                if( $e =~ m/\A([^ ]+?)[:][ ]*(.+?)\z/i ) {
                    # split the line into a header name and a header content
                    my $x = $1;
                    my $y = $2;

                    $currheader = lc $x;
                    next unless grep { $currheader eq lc $_ } @$headerlist;

                    if( grep { $currheader eq lc $_ } @$multiheads ) {
                        # Such as 'Received' header, there are multiple headers
                        # in a single email message.
                        $y =~ y{\t}{ };
                        $y =~ y{ }{}s;
                        push @{ $processing->{'header'}->{ $currheader } }, $y;

                    } else {
                        $processing->{'header'}->{ $currheader } = $y;
                    }

                } elsif( $e =~ m/\A[\s\t]+(.+?)\z/ ) {
                    # Ignore header?
                    next if grep { $currheader eq lc $_ } @$ignorelist;

                    # Header line continued from the previous line
                    if( ref $processing->{'header'}->{ $currheader } eq 'ARRAY' ) {
                        # Concatenate a header which have multi-lines such as 'Received'
                        $processing->{'header'}->{ $currheader }->[ -1 ] .= ' '.$1;
                    } else {
                        $processing->{'header'}->{ $currheader } .= ' '.$1;
                    }
                }
            } # End of for(SPLIT_HEADERS)
        }

        REWRITE_BODY: {
            # 3. Rewrite message body for detecting the bounce reason
            require Sisimai::MTA;
            $bodystring .= Sisimai::MTA->EOM;
            $methodargv  = { 'mail' => $processing, 'body' => \$bodystring };
            $bouncedata  = __PACKAGE__->rewrite( %$methodargv );
        }

        return undef unless $bouncedata;
        return undef unless keys %$bouncedata;
        return undef unless $bodystring;
        $processing->{'ds'} = $bouncedata->{'ds'};

        REWRITE_RFC822_PART: {
            # Rewrite headers of the original message in the body part
            require Sisimai::String;
            require Sisimai::MIME;

            # Convert from string to hash reference
            my $v          = $bouncedata->{'rfc822'} // $bodystring;
            my $rfc822text = [ split( "\n", $v ) ];
            my $rfc822head = Sisimai::MTA->RFC822HEADERS;
            my $previousfn = ''; # Previous field name
            my $borderline = '__MIME_ENCODED_BOUNDARY__';
            my $mimeborder = {};

            for my $e ( @$rfc822text ) {
                # Header name as a key, The value of header as a value
                if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                    # Header
                    my $lhs = $1;
                    my $rhs = $2;

                    $previousfn = '';
                    next unless grep { lc $lhs eq lc $_ } @$rfc822head;
                    $previousfn = lc $lhs;
                    $rfc822part->{ $previousfn } //= $rhs;

                } else {
                    # Continued line from the previous line
                    next unless $e =~ m/\A[\s\t]+/;
                    next unless $previousfn;

                    # Concatenate the line if it is the value of required header
                    if( Sisimai::MIME->is_mimeencoded( \$e ) ) {
                        # The line is MIME-Encoded test
                        if( $previousfn eq 'subject' ) {
                            # Subject: header
                            $rfc822part->{ $previousfn } .= $borderline.$e;
                        } else {
                            # Is not Subject header
                            $rfc822part->{ $previousfn } .= $e;
                        }
                        $mimeborder->{ $previousfn } = 1;

                    } else {
                        # ASCII Characters only: Not MIME-Encoded
                        $rfc822part->{ $previousfn } .= $e;
                        $mimeborder->{ $previousfn }  = 0;
                    }
                }
            }

            if( $rfc822part->{'subject'} ) {
                # Convert MIME-Encoded subject
                my $v = $rfc822part->{'subject'};

                if( Sisimai::String->is_8bit( \$v ) ) {
                    # The value of ``Subject'' header is including multibyte character,
                    # is not MIME-Encoded text.
                    $v = 'MULTIBYTE CHARACTERS HAVE BEEN REMOVED';

                } else {
                    # MIME-Encoded subject field or ASCII characters only
                    if( Sisimai::MIME->is_mimeencoded( \$v ) ) {
                        # MIME-Encoded subject such as ISO-2022-JP, UTF-8...
                        my $r = [ $v ];

                        $r = [ split( $borderline, $v ) ] if $mimeborder->{'subject'};
                        $v = Sisimai::MIME->mimedecode( $r );
                    }
                }
                $rfc822part->{'subject'} = $v;
            } 
        } # End of REWRITE_HEADER_IN_BODY

        $processing->{'rfc822'} = $rfc822part // '';

    } # End of EMAIL_PROCESSING

    return undef unless length $processing->{'rfc822'};
    return $processing;
}

sub rewrite {
    # @Description  Break the header of the message, and return its body
    # @Param <ref>  (Ref->Hash) Processing message entity.
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Array) List of headers
    my $class = shift;
    my $argvs = { @_ };

    my $mesgentity = $argvs->{'mail'} || return '';
    my $bodystring = $argvs->{'body'} || return '';
    my $mailheader = $mesgentity->{'header'};
    my $scannedset = undef;

    FALLBACK_FOR_EACH_HEADER: {
        # Set empty string if the value is undefined
        $mailheader->{'from'}         //= '';
        $mailheader->{'subject'}      //= '';
        $mailheader->{'content-type'} //= '';
    }

    EXPAND_FORWARDED_MESSAGE: {
        # Check whether or not the message is a bounce mail.
        # Pre-Process email body if it is a forwarded bounce message.
        # Get the original text when the subject begins from 'fwd:' or 'fw:'
        if( lc $mailheader->{'subject'} =~ m{\A\s*fwd?:} ) {
            # Delete quoted strings, quote symbols(>)
            $$bodystring =~ s{\A.+?[>]}{>}s;
            $$bodystring =~ s{^[>]+[ ]}{}gm;
            $$bodystring =~ s{^[>]$}{}gm;
        }
    }

    SCANNER: while(1) {
        # 1. Sisimai::ARF 
        # 2. Sisimai::MTA::*
        # 3. Sisimai::MSP::*
        # 4. Sisimai::RFc3464
        #
        if( Sisimai::ARF->is_arf( $mailheader->{'content-type'} ) ) {
            # Feedback Loop message
            $scannedset = Sisimai::ARF->scan( $mailheader, $bodystring );
            last(SCANNER) if $scannedset;
        }

        MTA: for my $r ( @$DefaultMTA ) {
            # Pre-process email headers of a bounce message in standard format.
            # Famous MTAs, such as Sendmail, Postfix, and qmail...
            my $v = 'Sisimai::MTA::'.$r;
            $scannedset = $v->scan( $mailheader, $bodystring );
            last(MTA) if $scannedset;
        }
        last(SCANNER) if $scannedset;

        MSP: for my $r ( @$DefaultMSP ) {
            # Pre-process email headers of a bounce message in standard format.
            # Famous MSP: Mail Service Providers.
            my $v = 'Sisimai::MSP::'.$r;
            $scannedset = $v->scan( $mailheader, $bodystring );
            last(MSP) if $scannedset;
        }
        last(SCANNER) if $scannedset;

        # When the all of Sisimai::MTA::* modules did not return bounce data,
        # call Sisimai::RFC3464;
        #
        require Sisimai::RFC3464;
        $scannedset = Sisimai::RFC3464->scan( $mailheader, $bodystring );
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

Sisimai::Message - Convert email text to data structure.

=head1 SYNOPSIS

    use Sisimai::Mail;
    use Sisimai::Message;

    my $mailbox = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mailbox->read ) {
        my $p = Sisimai::Message->new( 'data' => $r );
    }

=head1 DESCRIPTION

Sisimai::Message convert email text to data structure. It resolve email text
into an UNIX From line, the header part of the mail, delivery status, and RFC822
header part.

=head1 CLASS METHODS

=head2 C<B<new( I<Hash reference> )>>

C<new()> is a constructor of Sisimai::Message

    my $mailtxt = 'Entire email text';
    my $message = Sisimai::Message->new( 'data' => $mailtxt );

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

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
