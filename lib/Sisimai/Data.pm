package Sisimai::Data;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load '';

use Sisimai::Address;
use Sisimai::RFC3463;
use Sisimai::RFC5322;
use Sisimai::RFC5321;
use Sisimai::String;
use Sisimai::Reason;
use Sisimai::Rhost;
use Sisimai::Time;
use Sisimai::DateTime;

my $rwaccessors = [
    'token',            # (String) Message token/MD5 Hex digest value
    'lhost',            # (String) local host name/Local MTA
    'rhost',            # (String) Remote host name/Remote MTA
    'alias',            # (String) Alias of the recipient address
    'listid',           # (String) List-Id header of each ML
    'reason',           # (String) Bounce reason
    'action',           # (String) The value of Action: header
    'subject',          # (String) UTF-8 Subject text
    'timestamp',        # (Sisimai::Time) Date: header in the original message
    'addresser',        # (Sisimai::Address) From address
    'recipient',        # (Sisimai::Address) Recipient address which bounced
    'messageid',        # (String) Message-Id: header
    'replycode',        # (String) SMTP Reply Code
    'smtpagent',        # (String) MTA name
    'softbounce',       # (Integer) 1 = Soft bounce, 0 = Hard bounce, -1 = ?
    'smtpcommand',      # (String) The last SMTP command
    'destination',      # (String) The domain part of the "recipinet"
    'senderdomain',     # (String) The domain part of the "addresser"
    'feedbacktype',     # (String) Feedback Type
    'diagnosticcode',   # (String) Diagnostic-Code: Header
    'diagnostictype',   # (String) The 1st part of Diagnostic-Code: Header
    'deliverystatus',   # (String) Delivery Status(DSN)
    'timezoneoffset',   # (Integer) Time zone offset(seconds)
];
Class::Accessor::Lite->mk_accessors( @$rwaccessors );

sub new {
    # @Description  Constructor of Sisimai::Data
    # @Param <ref>  (Ref->Hash) Data
    # @Return       (Sisimai::Data) Structured email data
    my $class = shift;
    my $argvs = { @_ };
    my $thing = {};

    EMAIL_ADDRESS: {
        # Create email address object
        my $x0 = Sisimai::Address->parse( [ $argvs->{'addresser'} ] );
        my $y0 = Sisimai::Address->parse( [ $argvs->{'recipient'} ] );

        if( ref $x0 eq 'ARRAY' ) {
            my $v = Sisimai::Address->new( shift @$x0 );

            if( ref $v eq 'Sisimai::Address' ) {
                $thing->{'addresser'} = $v;
                $thing->{'senderdomain'} = $v->host;
            }
        }

        if( ref $y0 eq 'ARRAY' ) {
            my $v = Sisimai::Address->new( shift @$y0 );

            if( ref $v eq 'Sisimai::Address' ) {
                $thing->{'recipient'} = $v;
                $thing->{'destination'} = $v->host;
                $thing->{'alias'} = $argvs->{'alias'};
            }
        }
    }
    return undef unless ref $thing->{'recipient'} eq 'Sisimai::Address';
    return undef unless ref $thing->{'addresser'} eq 'Sisimai::Address';

    $thing->{'token'} = Sisimai::String->token( 
                            $thing->{'addresser'}->address,
                            $thing->{'recipient'}->address,
                            $argvs->{'timestamp'} );

    TIMESTAMP: {
        # Create Sisimai::Time object
        $thing->{'timestamp'} = localtime Sisimai::Time->new( $argvs->{'timestamp'} );
        $thing->{'timezoneoffset'} = $argvs->{'timezoneoffset'} // '+0000';
    }

    OTHER_VALUES: {
        my @v = ( 
            'listid', 'subject', 'messageid', 'smtpagent', 'diagnosticcode',
            'diagnostictype', 'deliverystatus', 'reason', 'lhost', 'rhost', 
            'smtpcommand', 'feedbacktype', 'action', 'softbounce',
        );
        $thing->{ $_ } = $argvs->{ $_ } // '' for @v;
        $thing->{'replycode'} = Sisimai::RFC5321->getrc( $argvs->{'diagnosticcode'} );
    }
    return bless( $thing, __PACKAGE__ );
}

sub make {
    # @Description  Another constructor of Sisimai::Data
    # @Param <ref>  (Hash) Data and orders
    # @Return       (Ref->Array) List of Sisimai::Data
    my $class = shift;
    my $argvs = { @_ };

    return undef unless exists $argvs->{'data'};
    return undef unless ref $argvs->{'data'} eq 'Sisimai::Message';

    my $messageobj = $argvs->{'data'};
    my $rfc822data = $messageobj->rfc822;
    my $fieldorder = { 'recipient' => [], 'addresser' => [] };
    my $objectlist = [];
    my $endofemail = '';
    my $rxcommands = qr/\A(?:EHLO|HELO|MAIL|RCPT|DATA|QUIT)\z/;

    return undef unless $messageobj->ds;
    return undef unless $messageobj->rfc822;

    ORDER_OF_HEADERS: {
        # Decide the order of email headers: user specified or system default.
        my $o = exists $argvs->{'order'} ? $argvs->{'order'} : {};
        if( ref $o eq 'HASH' && scalar keys %$o ) {
            # If the order of headers for searching is specified, use the order
            # for detecting an email address.
            for my $e ( 'recipient', 'addresser' ) {
                # The order should be "Array Reference".
                next unless $o->{ $e };
                next unless ref $o->{ $e } eq 'ARRAY';
                next unless scalar @{ $o->{ $e } };
                push @{ $fieldorder->{ $e } }, @{ $o->{ $e } };
            }
        }

        for my $e ( 'recipient', 'addresser' ) {
            # If the order is empty, use default order.
            if( not scalar @{ $fieldorder->{ $e } } ) {
                # Load default order of each accessor.
                Module::Load::load 'Sisimai::MTA';
                $fieldorder->{ $e } = Sisimai::MTA->RFC822HEADERS( $e );
            }
        }
    }
    $endofemail = Sisimai::MTA->EOM();

    LOOP_DELIVERY_STATUS: for my $e ( @{ $messageobj->ds } ) {
        # Create parameters for new() constructor.
        my $o = undef;  # Sisimai::Data Object
        my $r = undef;  # Reason text
        my $p = {
            'lhost'          => $e->{'lhost'}        // '',
            'rhost'          => $e->{'rhost'}        // '',
            'alias'          => $e->{'alias'}        // '',
            'action'         => $e->{'action'}       // '',
            'reason'         => $e->{'reason'}       // '',
            'smtpagent'      => $e->{'agent'}        // '',
            'recipient'      => $e->{'recipient'}    // '',
            'softbounce'     => $e->{'softbounce'}   // '',
            'smtpcommand'    => $e->{'command'}      // '',
            'feedbacktype'   => $e->{'feedbacktype'} // '',
            'diagnosticcode' => $e->{'diagnosis'}    // '',
            'diagnostictype' => $e->{'spec'}         // '',
            'deliverystatus' => $e->{'status'}       // '',
        };
        next if $p->{'deliverystatus'} =~ m/\A2[.]/;

        EMAIL_ADDRESS: {
            # Detect email address from message/rfc822 part
            for my $f ( @{ $fieldorder->{'addresser'} } ) {
                # Check each header in message/rfc822 part
                my $h = lc $f;
                next unless exists $rfc822data->{ $h };
                next unless length $rfc822data->{ $h };
                next unless Sisimai::RFC5322->is_emailaddress( $rfc822data->{ $h } );
                $p->{'addresser'} = $rfc822data->{ $h };
                last;
            }

            # Fallback: Get the sender address from the header of the bounced
            # email if the address is not set at loop above.
            $p->{'addresser'} ||= $messageobj->{'header'}->{'to'}; 

        } # End of EMAIL_ADDRESS
        next unless $p->{'addresser'};
        next unless $p->{'recipient'};

        TIMESTAMP: {
            # Convert from a time stamp or a date string to a machine time.
            my $datestring = undef;
            my $zoneoffset = 0;
            my @datevalues = ();

            push @datevalues, $e->{'date'} if $e->{'date'};

            # Date information did not exist in message/delivery-status part,...
            for my $f ( @{ Sisimai::MTA->RFC822HEADERS('date') } ) {
                # Get the value of Date header or other date related header.
                next unless $rfc822data->{ lc $f };
                push @datevalues, $rfc822data->{ lc $f };
            }

            if( scalar( @datevalues ) < 2 ) {
                # Set "date" getting from the value of "Date" in the bounce message
                push @datevalues, $messageobj->{'header'}->{'date'}; 
            }

            while( my $v = shift @datevalues ) {
                # Parse each date value in the array
                $datestring = Sisimai::DateTime->parse( $v );
                last if $datestring;
            }

            if( defined $datestring ) {
                # Get the value of timezone offset from $datestring
                if( $datestring =~ m/\A(.+)\s+([-+]\d{4})\z/ ) {
                    # Wed, 26 Feb 2014 06:05:48 -0500
                    $datestring = $1;
                    $zoneoffset = Sisimai::DateTime->tz2second($2);
                    $p->{'timezoneoffset'} = $2;
                }
            }

            eval {
                # Convert from the date string to an object then calculate time
                # zone offset.
                my $t = Sisimai::Time->strptime( $datestring, '%a, %d %b %Y %T' );
                $p->{'timestamp'} = ( $t->epoch - $zoneoffset ) // undef; 
            };
        }
        next unless $p->{'timestamp'};

        OTHER_TEXT_HEADERS: {
            # Remove square brackets and curly brackets from the host variable
            map { $p->{ $_ } =~ y/[]()//d } ( 'rhost', 'lhost' ); 

            # Remove string before "="
            map { $p->{ $_ } =~ s/\A.+=// } ( 'rhost', 'lhost' );

            for my $e ( 'rhost', 'lhost' ) {
                # Check space character in each value
                if( $p->{ $e } =~ m/ / ) {
                    # Get the first element
                    $p->{ $e } = (split( ' ', $p->{ $e }, 2 ))[0];
                }
            }
            $p->{'subject'} = $rfc822data->{'subject'} // '';

            # The value of "List-Id" header
            $p->{'listid'} =  $rfc822data->{'list-id'} // '';
            if( length $p->{'listid'} ) {
                # Get the value of List-Id header
                if( $p->{'listid'} =~ m/\A.*([<].+[>]).*\z/ ) {
                    # List name <list-id@example.org>
                    $p->{'listid'} =  $1 
                }
                $p->{'listid'} =~ y/<>//d;
                $p->{'listid'} =  '' if $p->{'listid'} =~ m/ /;
            }

            # The value of "Message-Id" header
            $p->{'messageid'} =  $rfc822data->{'message-id'} // '';
            if( length $p->{'messageid'} ) {
                # Remove angle brackets
                $p->{'messageid'} =  $1 if $p->{'messageid'} =~ m/\A([^ ]+)[ ].*/;
                $p->{'messageid'} =~ y/<>//d;
            }

            CHECK_DELIVERY_STATUS_VALUE: {
                # Cleanup the value of "Diagnostic-Code:" header
                $p->{'diagnosticcode'} =~ s/\s+$endofemail//;
                my $v = Sisimai::RFC3463->getdsn( $p->{'diagnosticcode'} );
                if( $v =~ m/\A[45][.][1-9][.][1-9]\z/ ) {
                    # Use the DSN value in Diagnostic-Code:
                    $p->{'deliverystatus'} = $v;
                }
            }

            # Check the value of SMTP command
            $p->{'smtpcommand'} = '' unless $p->{'smtpcommand'} =~ $rxcommands;
        }

        $o = __PACKAGE__->new( %$p );
        next unless defined $o;

        if( $o->reason eq '' || grep { $o->reason eq $_ } @{ Sisimai::Reason->retry } ) {
            # Decide the reason of email bounce
            if( Sisimai::Rhost->match( $o->rhost ) ) {
                # Remote host dependent error
                $r = Sisimai::Rhost->get( $o );
            }
            $r ||= Sisimai::Reason->get( $o );
            $r ||= 'undefined';
            $o->reason( $r );
        }

        if( $o->reason ne 'feedback' && $o->reason ne 'vacation' ) {
            # Bounce message which reason is "feedback" or "vacation" does
            # not have the value of "deliverystatus".
            unless( length $o->softbounce ) {
                # The value is not set yet
                for my $v ( 'deliverystatus',  'diagnosticcode' ) {
                    # Set the value of softbounce
                    next unless length $p->{ $v };
                    $o->softbounce( Sisimai::RFC3463->is_softbounce( $p->{ $v } ) );
                    last if $o->softbounce > -1;
                }
                $o->softbounce(-1) unless length $o->softbounce;
            }

            unless( $o->deliverystatus ) {
                # Set pseudo status code
                my $pdsv = undef; # Pseudo delivery status value
                my $torp = undef; # Temporary or Permanent

                $torp = $o->softbounce == 1 ? 't' : 'p';
                $pdsv = Sisimai::RFC3463->status( $o->reason, $torp, 'i' );

                if( length $pdsv ) {
                    # Set the value of "deliverystatus" and "softbounce".
                    $o->deliverystatus( $pdsv );
                    $o->softbounce( Sisimai::RFC3463->is_softbounce( $pdsv ) ) if $o->softbounce < 0;
                }
            }
        } else {
            # The value of reason is "vacation" or "feedback"
            $o->softbounce(-1);
        }

        push @$objectlist, $o;

    } # End of for(LOOP_DELIVERY_STATUS)

    return $objectlist;
}

sub damn {
    # @Description  Convert from object to hash reference
    # @Param        <None>
    # @Return       (Ref->Hash) Data in Hash reference
    my $self = shift;
    my $data = undef;

    eval {
        my $v = {};
        my @stringdata = ( qw|
            token lhost rhost listid alias reason subject messageid smtpagent 
            smtpcommand destination diagnosticcode senderdomain deliverystatus
            timezoneoffset feedbacktype diagnostictype action replycode
            softbounce|
        );

        for my $e ( @stringdata ) {
            # Copy string data
            $v->{ $e } = $self->$e // '';
        }
        $v->{'addresser'} = $self->addresser->address;
        $v->{'recipient'} = $self->recipient->address;
        $v->{'timestamp'} = $self->timestamp->epoch;
        $data = $v;
    };

    return $data;
}

sub dump {
    # @Description  Data dumper
    # @Param <str>  (String) Data format: json, yaml
    # @Return       (String) Dumped data
    my $self = shift;
    my $argv = shift || 'json';

    return undef unless $argv =~ m/\A(?:json|yaml)\z/;

    my $dumpeddata = '';
    my $referclass = sprintf( "Sisimai::Data::%s", uc $argv );

    eval { Module::Load::load $referclass };
    $dumpeddata = $referclass->dump( $self );

    return $dumpeddata;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Data - Parsed data object

=head1 SYNOPSIS

    use Sisimai::Data;
    my $data = Sisimai::Data->make( 'data' => <Sisimai::Message> object );
    for my $e ( @$data ) {
        print $e->reason;               # userunknown, mailboxfull, and so on.
        print $e->recipient->address;   # (Sisimai::Address) envelope recipient address
        print $e->bonced->ymd           # (Sisimai::Time) Date of bounce
    }

=head1 DESCRIPTION

Sisimai::Data generate parsed data from Sisimai::Message object.

=head1 CLASS METHODS

=head2 C<B<make( I<Hash> )>>

C<make> generate parsed data and returns an array reference which are 
including Sisimai::Data objects.

    my $mail = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mail->read ) {
        my $mesg = Sisimai::Message->new( 'data' => $r );
        my $data = Sisimai::Data->make( 'data' => $mesg );
        for my $e ( @$data ) {
            print $e->reason;               # userunknown, mailboxfull, and so on.
            print $e->recipient->address;   # (Sisimai::Address) envelope recipient address
            print $e->timestamp->ymd        # (Sisimai::Time) Date of the email bounce
        }
    }

=head1 INSTANCE METHODS

=head2 C<B<damn()>>

C<damn> convert the object to a hash reference.

    my $hash = $self->damn;
    print $hash->{'recipient'}; # user@example.jp
    print $hash->{'timestamp'}; # 1393940000

=head1 PROPERTIES

Sisimai::Data have the following properties:

=head2 C<action> (I<String>)

C<action> is the value of Action: field in a bounce email message such as 
C<failed> or C<delayed>.

    Action: failed

=head2 C<addresser> (I<Sisimai::Address)>

C<addressser> is L<Sisimai::Address> object generated from the sender address.
When Sisimai::Data object is dumped as JSON, this value converted to an email
address. Sisimai::Address object have the following accessors:

=over

=item - user() - the local part of the address

=item - host() - the domain part of the address

=item - address() - email address

=item - verp() - variable envelope return path

=item - alias() - alias of the address

=back

    From: "Kijitora Cat" <kijitora@example.org>

=head2 C<alias> (I<String>)

C<alias> is an alias address of the recipient. When the Original-Recipient: 
field or C<expanded from 窶ｦ> string  did not exist in a bounce message, this 
value is empty.

    Original-Recipient: rfc822;kijitora@example.org

    "|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #kijitora"
        (expanded from: <kijitora@neko.example.edu>)

=head2 C<deliverystatus> (I<String>)

C<deliverystatus> is the value of Status: field in a bounce message. When the
message has no Status: field, Sisimai set pseudo value like 5.0.9XX to this 
value. The range of values only C<4.x.x> or C<5.x.x>.

    Status: 5.0.0 (permanent failure)

=head2 C<destination> (I<String>)

C<destination> is the domain part of the recipient address. This value is the
same as the return value from host() method of C<recipient> accessor.

=head2 C<diagnosticcode> (I<String>)

C<diagnosticcode> is an error message picked from Diagnostic-Code: field or 
message body in a bounce message. This value and the value of C<diagnostictype>,
C<action>, C<deliverystatus>, C<replycode>, and C<smtpcommand> will be referred
by L<Sisimai::Reason> to decide the bounce reason. 

    Diagnostic-Code: SMTP; 554 5.4.6 Too many hops

=head2 C<diagnostictype> (C<String>)

C<diagnostictype> is a type like C<SMTP> or C<X-Unix> picked from Diagnostic-Code:
field in a bounce message. When there is no Diagnostic-Code: field in the bounce
message, this value will be empty.

    Diagnostic-Code: X-Unix; 255

=head2 C<feedbacktype> (I<String>)

C<feedbacktype> is the value of Feedback-Type: field like C<abuse>, C<fraud>,
C<opt-out> in a bounce message. When the message is not ARF format or the value
of C<reason> is not C<feedback>, this value will be empty.

    Content-Type: message/feedback-report

    Feedback-Type: abuse
    User-Agent: SMP-FBL

=head2 C<lhost> (I<String>)

C<lhost> is a local MTA name to be used as a gateway for sending email message
or the value of Reporting-MTA field in a bounce message. When there is no
Reporting-MTA field in the bounce message, Sisimai try to get the value from 
Received header.

    Reporting-MTA: dns; mx4.smtp.example.co.jp

=head2 C<listid> (I<String>)

C<listid> is the value of List-Id header of the original message. When there
is no List-Id field in the original message or the bounce message did not 
include the original message, this value will be empty.

    List-Id: Mailman mailing list management users 

=head2 C<messageid> (I<String>)

C<messageid> is the value of Message-Id header of the original message. When 
the original message did not include Message-Id: header or the bounce message
did not include the original message, this value will be empty.

    Message-Id: <201310160515.r9G5FZh9018575@smtpgw.example.jp>
 

=head2 C<recipient> (I<Sisimai::Address)>

C<recipient> is L<Sisimai::Address> object generated from the recipient address.
When Sisimai::Data object is dumped as JSON, this value converted to an email
address. Sisimai::Address object have the following accessors:

=over

=item - user() - the local part of the address

=item - host() - the domain part of the address

=item - address() - email address

=item - verp() - variable envelope return path

=item - alias() - alias of the address

=back

    Final-Recipient: RFC822; shironeko@example.ne.jp
    X-Failed-Recipients: kijitora@example.ed.jp

=head2 C<reason> (I<String>)

C<reason> is the value of bounce reason Sisimai detected. When this value is 
C<undefined> or C<onhold>, it means that Sisimai could not decide the reason. 
All the reasons Sisismai can detect are available at L<Sisimai::Reason> or web
site L<http://libsisimai.org/reason>.

=head2 C<replycode> (I<Integer>)

C<replyacode> is the value of SMTP reply code picked from the error message or 
the value of Diagnostic-Code: field in a bounce message. The range of values is
only 4xx or 5xx.

       ----- The following addresses had permanent fatal errors -----
    <userunknown@libsisimai.org>
        (reason: 550 5.1.1 <userunknown@libsisimai.org>... User Unknown)

=head2 C<rhost> (I<String>)

C<rhost> is a remote MTA name which has rejected the message you sent or the
value of Remote-MTA: field in a bounce message. When there is no Remote-MTA 
field in the bounce message, Sisimai try to get the value from Received header.

    Remote-MTA: DNS; g5.example.net

=head2 C<senderdomain> (I<String>)

C<senderdomain> is the domain part of the sender address. This value is the same
as the return value from host() method of addresser accessor.

=head2 C<smtpagent> (I<String>)

C<smtpagent> is a module name to be used for detecting bounce reason. For 
example, when the value is C<Sendmail>, Sisimai used L<Sisimai::MTA::Sendmail>
to get the recipient address and other delivery status information from a 
bounce message.

=head2 C<smtpcommand> (I<String>)

C<smtpcommand> is a SMTP command name picked from the error message or the value
of Diagnostic-Code: field in a bounce message. When there is no SMTP command in
the bounce message, this value will be empty. The list of values is C<HELO>,
C<EHLO>, C<MAIL>, C<RCPT>, and C<DATA>.

    <kijitora@example.go.jp>: host mx1.example.go.jp[192.0.2.127] said: 550 5.1.6 recipient
        no longer on server: kijitora@example.go.jp (in reply to RCPT TO command)

=head2 C<softbounce> (I<Integer>)

The value of C<softbounce> indicates whether the reason of the bounce is soft
bounce or hard bounce. This accessor has added in Sisimai 4.1.28. The range of
the values are the followings:

=over

=item 1 = Soft bounce

=item 0 = Hard bounce

=item -1 = Sisimai could not decide

=back

=head2 C<subject> (I<String>)

C<subject> is the value of Subject header of the original message. When the 
original message which is included in a bounce email contains no Subject header 
(removed by remote MTA), this value will be empty. 
If the value of Subject header of the original message contain any multibyte 
character (non ASCII character), such as MIME encoded Japanese or German and so
on, the value of subject in parsed data is encoded with UTF-8 again.

=head2 C<token> (I<String>)

C<token> is an identifier of each email-bounce. The token string is created from
the sender email address (addresser) and the recipient email address (recipient)
and the machine time of the date in a bounce message as an MD5 hash value. 
The token value is generated at C<token()> method of L<Sisimai::String> class.

If you want to get the same token string at command line, try to run the 
following comand:

    % printf "\x02%s\x1e%s\x1e%d\x03" sender@example.jp recipient@example.org `date '+%s'` | md5
    714d72dfd972242ad04f8053267e7365

=head2 C<timestamp> (I<Sisimai::Time>)

C<timestamp> is the date which email has bounced as a L<Sisima::Time> (Child 
class of Time::Piece) object. When Sisimai::Data object is dumped as JSON, this
value will be converted to an UNIX machine time (32 bits integer).

    Arrival-Date: Thu, 29 Apr 2009 23:45:33 +0900

=head2 C<timezomeoffset> (I<String>)

C<timezoneoffset> is a time zone offset of a bounce email which its email has
bounced. The format of this value is String like C<+0900>, C<-0200>.
If Sisimai has failed to get a value of time zone offset, this value will be 
set as C<+0000>.

=head1 SEE ALSO

L<http://libsisimai.org/data/>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
