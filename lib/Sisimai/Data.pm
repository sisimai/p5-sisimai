package Sisimai::Data;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Module::Load;
use Time::Piece;
use Try::Tiny;

use Sisimai::Address;
use Sisimai::RFC5322;
use Sisimai::String;
use Sisimai::Reason;
use Sisimai::Group;
use Sisimai::Rhost;
use Sisimai::Time;

my $rwaccessors = [
    'date',             # (Time::Piece) Date: in the original message
    'token',            # (String) Message token/MD5 Hex digest value
    'lhost',            # (String) local host name
    'rhost',            # (String) Remote host name
    'alias',            # (String) The value of alias(RHS)
    'listid',           # (String) List-Id header of each ML
    'reason',           # (String) Bounce reason
    'subject',          # (String) UTF-8 Subject text
    'provider',         # (String) Provider name
    'category',         # (String) Host group name
    'addresser',        # (Sisimai::Address) From: header in the original message
    'recipient',        # (Sisimai::Address) Final-Recipient: or To: in the original message
    'messageid',        # (String) Message-Id: header
    'smtpagent',        # (String) MTA name
    'smtpcommand',      # (String) The last SMTP command
    'destination',      # (String) A domain part of the "recipinet"
    'senderdomain',     # (String) A domain part of the "addresser"
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
    return undef if( ! $thing->{'recipient'} && ! $thing->{'addresser'} );

    $thing->{'token'} = Sisimai::String->token( 
                            $thing->{'addresser'}->address,
                            $thing->{'recipient'}->address );

    TIMESTAMP: {
        # Create Time::Piece object
        $thing->{'date'} = localtime Time::Piece->new( $argvs->{'date'} );
        $thing->{'timezoneoffset'} = $argvs->{'timezoneoffset'} // '+0000';
    }

    OTHER_VALUES: {
        my $v = [ 
            'listid', 'subject', 'messageid', 'smtpagent', 'diagnosticcode',
            'diagnostictype', 'deliverystatus', 'reason', 'category', 'provider',
            'lhost', 'rhost', 'smtpcommand', 'feedbacktype',
        ];
        $thing->{ $_ } = $argvs->{ $_ } // '' for @$v;
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

    return undef unless $messageobj->ds;
    return undef unless $messageobj->rfc822;

    ORDER_OF_HEADERS: {
        # Decide the order of email headers: user specified or system default.
        if( exists $argvs->{'order'} && ref $argvs->{'order'} eq 'HASH' ) {
            # If the order of headers for searching is specified, use the order
            # for detecting an email address.
            for my $e ( 'recipient', 'addresser' ) {
                # The order should be "Array Reference".
                next unless $argvs->{'order'}->{ $e };
                next unless ref $argvs->{'order'}->{ $e } eq 'ARRAY';
                next unless scalar @{ $argvs->{'order'}->{ $e } } eq 'ARRAY';
                push @{ $fieldorder->{ $e } }, @{ $argvs->{'order'}->{ $e } };
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

    LOOP_DELIVERY_STATUS: for my $e ( @{ $messageobj->ds } ) {
        # Create parameters for new() constructor.
        my $o = undef;  # Sisimai::Data Object
        my $r = undef;  # Reason text
        my $p = {
            'lhost'          => $e->{'lhost'}        // '',
            'rhost'          => $e->{'rhost'}        // '',
            'alias'          => $e->{'alias'}        // '',
            'reason'         => $e->{'reason'}       // '',
            'smtpagent'      => $e->{'agent'}        // '',
            'recipient'      => $e->{'recipient'}    // '',
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

            if( length $p->{'recipient'} == 0 ) {
                # Detect "recipient" address if it is not set yet
                for my $f ( @{ $fieldorder->{'recipient'} } ) {
                    # Check each header in message/rfc822 part
                    my $h = lc $f;
                    next unless exists $rfc822data->{ $h };
                    next unless length $rfc822data->{ $h };
                    next unless Sisimai::RFC5322->is_emailaddress( $rfc822data->{ $h } );
                    $p->{'recipient'} = $rfc822data->{ $h };
                    last;
                }
            }

        } # End of EMAIL_ADDRESS
        next unless $p->{'addresser'};
        next unless $p->{'recipient'};

        TIMESTAMP: {
            # Convert from a time stamp or a date string to a machine time.
            my $v = $e->{'date'};

            unless( $v ) {
                # Date information did not exist in message/delivery-status part,...
                for my $f ( @{ Sisimai::MTA->RFC822HEADERS('date') } ) {
                    # Get the value of Date header or other date related header.
                    next unless $rfc822data->{ $f };
                    $v = $rfc822data->{ $f };
                    last;
                }

                unless( $v ) {
                    # Set "date" getting from the value of "Date" in the bounce
                    # message
                    $v= $messageobj->{'header'}->{'date'}; 
                }
            }

            my $datestring = Sisimai::Time->parse( $v );
            my $zoneoffset = 0;

            if( $datestring =~ m/\A(.+)\s+([-+]\d{4})\z/ ) {
                # Wed, 26 Feb 2014 06:05:48 -0500
                $datestring = $1;
                $zoneoffset = Sisimai::Time->tz2second($2);
                $p->{'timezoneoffset'} = $2;
            }

            try {
                # Convert from the date string to an object then calculate time
                # zone offset.
                my $t = Time::Piece->strptime( $datestring, '%a, %d %b %Y %T' );
                $p->{'date'} = ( $t->epoch - $zoneoffset ) // undef; 

            } catch {
                # Failed to parse the date string...
                warn $_;
            };
        }
        next unless $p->{'date'};

        OTHER_TEXT_HEADERS: {
            # Remove square brackets and curly brackets from the host variable
            map { $p->{ $_ } =~ y/[]()//d } ( 'rhost', 'lhost' );
            $p->{'subject'} = $rfc822data->{'subject'} // '';

            # The value of "List-Id" header
            $p->{'listid'} =  $rfc822data->{'list-id'} // '';
            $p->{'listid'} =~ y/<>//d if length $p->{'listid'};

            # The value of "Message-Id" header
            $p->{'messageid'} =  $rfc822data->{'message-id'} // '';
            $p->{'messageid'} =~ y/<>//d if length $p->{'messageid'};
        }

        CLASSIFICATION: {
            # Set host group and provider name
            my $v = Sisimai::Group->find( 'email' => $p->{'recipient'} ) // {};
            $p->{'provider'} = $v->{'provider'} // '';
            $p->{'category'} = $v->{'category'} // '';
        }

        $o = __PACKAGE__->new( %$p );
        next unless defined $o;

        if( $o->reason eq '' || $o->reason =~ m/\A(?:onhold|undefined)\z/ ) {
            # Decide the reason of email bounce
            if( Sisimai::Rhost->match( $o->rhost ) ) {
                # Remote host dependent error
                $r = Sisimai::Rhost->get( $o );
            }

            $r ||= Sisimai::Reason->get( $o );
            $o->reason( $r );
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

    try {
        my $v = {};
        my $stringdata = [ qw|
            token lhost rhost listid alias reason subject provider category 
            messageid smtpagent smtpcommand destination diagnosticcode
            senderdomain deliverystatus timezoneoffset feedbacktype|
        ];
        
        for my $e ( @$stringdata ) {
            # Copy string data
            $v->{ $e } = $self->$e // '';
        }
        $v->{'addresser'} = $self->addresser->address;
        $v->{'recipient'} = $self->recipient->address;
        $v->{'date'}      = $self->date->epoch;
        $data = $v;

    } catch {
        warn $_;
    };

    return $data;
}

sub dump {
    # @Description  Data dumper
    # @Param <str>  (String) Data format: json, csv
    # @Return       (String) Dumped data
    my $self = shift;
    my $argv = shift || 'json';

    return undef unless $argv =~ m/\A(?:json|csv)\z/;

    my $referclass = '';
    my $dumpeddata = '';

    try {
        $referclass = sprintf( "Sisimai::Data::%s", uc $argv );
        Module::Load::load $referclass;
        $dumpeddata = $referclass->dump( $self );

    } catch {
        warn $_;
    };

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
        print $e->bonced->ymd           # (Time::Piece) Date of bounce
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
            print $e->date->ymd             # (Time::Piece) Date of the email bounce
        }
    }

=head1 INSTANCE METHODS

=head2 C<B<damn()>>

C<damn> convert the object to a hash reference.

    my $hash = $self->damn;
    print $hash->{'recipient'}; # user@example.jp
    print $hash->{'date'};      # 1393940000

=head1 PROPERTIES

Sisimai::Data have the following properties:

=head2 C<date>(I<Time::Piece>)

The value of Date: header of the original message or the bounce message.

=head2 C<token>(I<String>)

C<token> is a MD5 string generated from the sender address(C<addresser>) and the
recipient address.

=head2 C<lhost>(I<String>)

Local host name of the email bounce.

=head2 C<rhost>(I<String>)

Remote MTA name of the email bounce.

=head2 C<alias>(I<String>)

Expanded address of the recipient address.

=head2 C<listid>(I<String>)

The value of C<List-Id> header of the original message. If the original message
have no such header, this value will be set "".

=head2 C<reason>(I<String>)

The reason name of email bounce. The list of all reasons are available at 
C<perldoc Sisimai::Reason>.

=head2 C<subject>(I<String>)

The value of C<Subject> header of the original message encoded in UTF-8.

=head2 C<provider>(I<String>)

Provider name of the recipient address. See C<perldoc Sisimai::Group>

=head2 C<category>(I<category>)

Cateogry name of the recipient address such as C<pc>, C<webmail>, and C<phone>. 
See C<perldoc Sisimai::Group>.

=head2 C<addresser>(I<Sisimai::Address)>

Sender address of the original message. See C<perldoc Sisimai::Address>.

=head2 C<recipienet>(I<Sisimai::Address)>

Recipient address of the original message. See C<perldoc Sisimai::Address>.

=head2 C<messageid>(I<String>)

The value of C<Message-Id> header of the original message. When the header does
not exist in the message, this value will be set "".

=head2 C<smtpagent>(I<String>)

MTA or MSP module name which is used to get bounce reason such as C<Sendmail>,
C<US::Google>, and so on. See C<perldoc Sisimai::MTA> or C<perldoc Sisimai::MSP>.

=head2 C<smtpcommand>(I<String>)

The last SMTP command name of the session email bounce has occurred.

=head2 C<destination>(I<String>)

the domain part of the c<recipient>.

=head2 C<senderdomain>(I<String>)

the domain part of the c<addresser>.

=head2 C<feedbacktype>(I<String>)

The value of C<Feedback-Type> header of ARF: Abuse Reporting Formatted message.

=head2 C<diagnosticcode>(I<String>)

The value of C<Diagnostic-Code> header or error message string in the bounced email.

=head2 C<diagnostictype>(I<String>)

C<SMTP> or C<X-Unix>.

=head2 C<deliverystatus>(I<String>)

The value of C<Status> header or pseudo D.S.N. value generated from bounce reason
or error message string and so on.

=head2 C<timezoneoffset>(I<Integer>)

Time zone offset value(seconds).

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
