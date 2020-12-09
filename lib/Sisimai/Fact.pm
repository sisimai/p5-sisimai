package Sisimai::Fact;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Message;
use Sisimai::RFC1894;
use Sisimai::RFC5322;
use Sisimai::Reason;
use Sisimai::Address;
use Sisimai::DateTime;
use Sisimai::Time;
use Sisimai::SMTP::Error;
use Sisimai::String;
use Sisimai::Rhost;
use Class::Accessor::Lite ('new' => 0, 'rw' => [
    'action',           # [String] The value of Action: header
    'addresser',        # [Sisimai::Address] From address
    'alias',            # [String] Alias of the recipient address
    'catch',            # [?] Results generated by hook method
    'deliverystatus',   # [String] Delivery Status(DSN)
    'destination',      # [String] The domain part of the "recipinet"
    'diagnosticcode',   # [String] Diagnostic-Code: Header
    'diagnostictype',   # [String] The 1st part of Diagnostic-Code: Header
    'feedbacktype',     # [String] Feedback Type
    'hardbounce',       # [Integer] 1 = Hard bounce, 0 = Is not a hard bounce
    'lhost',            # [String] local host name/Local MTA
    'listid',           # [String] List-Id header of each ML
    'messageid',        # [String] Message-Id: header
    'origin',           # [String] Email path as a data source
    'reason',           # [String] Bounce reason
    'recipient',        # [Sisimai::Address] Recipient address which bounced
    'replycode',        # [String] SMTP Reply Code
    'rhost',            # [String] Remote host name/Remote MTA
    'senderdomain',     # [String] The domain part of the "addresser"
    'smtpagent',        # [String] Module(Engine) name
    'smtpcommand',      # [String] The last SMTP command
    'subject',          # [String] UTF-8 Subject text
    'timestamp',        # [Sisimai::Time] Date: header in the original message
    'timezoneoffset',   # [Integer] Time zone offset(seconds)
    'token',            # [String] Message token/MD5 Hex digest value
]);

sub rise {
    # Constructor of Sisimai::Fact
    # @param         [Hash]   argvs
    # @options argvs [String]  data         Entire email message
    # @options argvs [Integer] delivered    Include the result which has "delivered" reason
    # @options argvs [Code]    hook         Code reference to callback method
    # @options argvs [Array]   load         User defined MTA module list
    # @options argvs [Array]   order        The order of MTA modules
    # @options argvs [String]  origin       Path to the original email file
    # @return        [Array]                Array of Sisimai::Fact objects
    my $class = shift;
    my $argvs = shift || return undef;
    die ' ***error: Sisimai::Fact->rise receives only a HASH reference as an argument' unless ref $argvs eq 'HASH';

    my $email = $argvs->{'data'} || return undef;
    my $loads = $argvs->{'load'} || undef;
    my $order = $argvs->{'order'}|| undef;
    my $args1 = { 'data' => $email, 'hook' => $argvs->{'hook'}, 'load' => $loads, 'order' => $order };
    my $mesg1 = Sisimai::Message->rise($args1) || return undef;

    return undef unless $mesg1->{'ds'};
    return undef unless $mesg1->{'rfc822'};

    state $retryindex = Sisimai::Reason->retry;
    state $rfc822head = Sisimai::RFC5322->HEADERFIELDS('all');
    state $actionlist = qr/\A(?:delayed|delivered|expanded|failed|relayed)\z/;

    my $deliveries = $mesg1->{'ds'};
    my $rfc822data = $mesg1->{'rfc822'};
    my $listoffact = [];

    RISEOF: for my $e ( @$deliveries ) {
        # Create parameters
        my $o = {}; # To be blessed and pushed into the array above at the end of the loop
        my $p = {
            'action'         => $e->{'action'}       // '',
            'alias'          => $e->{'alias'}        // '',
            'catch'          => $mesg1->{'catch'}    // undef,
            'deliverystatus' => $e->{'status'}       // '',
            'diagnosticcode' => $e->{'diagnosis'}    // '',
            'diagnostictype' => $e->{'spec'}         // '',
            'feedbacktype'   => $e->{'feedbacktype'} // '',
            'hardbounce'     => 0,
            'lhost'          => $e->{'lhost'}        // '',
            'origin'         => $argvs->{'origin'}   // '',
            'reason'         => $e->{'reason'}       // '',
            'recipient'      => $e->{'recipient'}    // '',
            'replycode'      => $e->{'replycode'}    // '',
            'rhost'          => $e->{'rhost'}        // '',
            'smtpagent'      => $e->{'agent'}        // '',
            'smtpcommand'    => $e->{'command'}      // '',
        };
        unless( $argvs->{'delivered'} ) {
            # Skip if the value of "deliverystatus" begins with "2." such as 2.1.5
            next RISEOF if index($p->{'deliverystatus'}, '2.') == 0;
        }

        EMAILADDRESS: {
            # Detect email address from message/rfc822 part
            for my $f ( @{ $rfc822head->{'addresser'} } ) {
                # Check each header in message/rfc822 part
                my $g = lc $f;
                next unless exists $rfc822data->{ $g };
                next unless $rfc822data->{ $g };

                my $j = Sisimai::Address->find($rfc822data->{ $g }) || next;
                $p->{'addresser'} = shift @$j;
                last;
            }

            unless( $p->{'addresser'} ) {
                # Fallback: Get the sender address from the header of the bounced email if the address
                # is not set at the loop above.
                my $j = Sisimai::Address->find($mesg1->{'header'}->{'to'}) || [];
                $p->{'addresser'} = shift @$j;
            }
        }
        next RISEOF unless $p->{'addresser'};
        next RISEOF unless $p->{'recipient'};

        TIMESTAMP: {
            # Convert from a time stamp or a date string to a machine time.
            my $datestring = undef;
            my $zoneoffset = 0;
            my @datevalues; push @datevalues, $e->{'date'} if $e->{'date'};

            # Date information did not exist in message/delivery-status part,...
            for my $f ( @{ $rfc822head->{'date'} } ) {
                # Get the value of Date header or other date related header.
                next unless $rfc822data->{ $f };
                push @datevalues, $rfc822data->{ $f };
            }

            # Set "date" getting from the value of "Date" in the bounce message
            push @datevalues, $mesg1->{'header'}->{'date'} if scalar(@datevalues) < 2;

            while( my $v = shift @datevalues ) {
                # Parse each date value in the array
                $datestring = Sisimai::DateTime->parse($v);
                last if $datestring;
            }

            if( defined $datestring && $datestring =~ /\A(.+)[ ]+([-+]\d{4})\z/ ) {
                # Get the value of timezone offset from $datestring: Wed, 26 Feb 2014 06:05:48 -0500
                $datestring = $1;
                $zoneoffset = Sisimai::DateTime->tz2second($2);
                $p->{'timezoneoffset'} = $2;
            }

            eval {
                # Convert from the date string to an object then calculate time zone offset.
                my $t = Sisimai::Time->strptime($datestring, '%a, %d %b %Y %T');
                $p->{'timestamp'} = ($t->epoch - $zoneoffset) // undef;
            };
        }
        next RISEOF unless $p->{'timestamp'};

        OTHER_TEXT_HEADERS: {
            # Scan "Received:" header of the original message
            my $recvheader = $mesg1->{'header'}->{'received'} || [];
            if( scalar @$recvheader ) {
                # Get localhost and remote host name from Received header.
                $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received($recvheader->[0]) };
                $e->{'rhost'} ||= pop   @{ Sisimai::RFC5322->received($recvheader->[-1]) };
            }

            for my $v ('rhost', 'lhost') {
                # Check and rewrite each host name
                $p->{ $v } =  [split('@', $p->{ $v })]->[-1] if index($p->{ $v }, '@') > -1;
                $p->{ $v } =~ y/[]()//d;    # Remove square brackets and curly brackets from the host variable
                $p->{ $v } =~ s/\A.+=//;    # Remove string before "="
                chop $p->{ $v } if substr($p->{ $v }, -1, 1) eq "\r";   # Remove CR at the end of the value

                # Check space character in each value and get the first element
                $p->{ $v } = (split(' ', $p->{ $v }, 2))[0] if rindex($p->{ $v }, ' ') > -1;
                chop $p->{ $v } if substr($p->{ $v }, -1, 1) eq '.';    # Remove "." at the end of the value
            }

            # Subject: header of the original message
            $p->{'subject'} = $rfc822data->{'subject'} // '';
            chop $p->{'subject'} if substr($p->{'subject'}, -1, 1) eq "\r";

            if( $p->{'listid'} = $rfc822data->{'list-id'} // '' ) {
                # Get the value of List-Id header: "List name <list-id@example.org>"
                $p->{'listid'} =  $1 if $p->{'listid'} =~ /\A.*([<].+[>]).*\z/;
                $p->{'listid'} =~ y/<>//d;
                chop $p->{'listid'} if substr($p->{'listid'}, -1, 1) eq "\r";
                $p->{'listid'} = '' if rindex($p->{'listid'}, ' ') > -1;
            }

            if( $p->{'messageid'} = $rfc822data->{'message-id'} // '' ) {
                # Leave only string inside of angle brackets(<>)
                $p->{'messageid'} = $1 if $p->{'messageid'} =~ /\A([^ ]+)[ ].*/;
                $p->{'messageid'} = $1 if $p->{'messageid'} =~ /[<]([^ ]+?)[>]/;
            }
        }

        CHECK_DELIVERYSTATUS_VALUE: {
            # Cleanup the value of "Diagnostic-Code:" header
            chop $p->{'diagnosticcode'} if substr($p->{'diagnosticcode'}, -1, 1) eq "\r";

            if( $p->{'diagnosticcode'} ) {
                # Count the number of D.S.N. and SMTP Reply Code
                my $vm = 0;
                my $vs = Sisimai::SMTP::Status->find($p->{'diagnosticcode'});
                my $vr = Sisimai::SMTP::Reply->find($p->{'diagnosticcode'});

                if( $vs ) {
                    # How many times does the D.S.N. appeared
                    $vm += 1 while $p->{'diagnosticcode'} =~ /\b\Q$vs\E\b/g;
                    $p->{'deliverystatus'} = $vs if $vs =~ /\A[45][.][1-9][.][1-9]+\z/;
                }

                if( $vr ) {
                    # How many times does the SMTP reply code appeared
                    $vm += 1 while $p->{'diagnosticcode'} =~ /\b$vr\b/g;
                    $p->{'replycode'} ||= $vr;
                }

                if( $vm > 2 ) {
                    # Build regular expression for removing string like '550-5.1.1' from the value of "diagnosticcode"
                    my $re = qr/[ ]$vr[- ](?:\Q$vs\E)?/;

                    # 550-5.7.1 [192.0.2.222] Our system has detected that this message is
                    # 550-5.7.1 likely unsolicited mail. To reduce the amount of spam sent to Gmail,
                    # 550-5.7.1 this message has been blocked. Please visit
                    # 550 5.7.1 https://support.google.com/mail/answer/188131 for more information.
                    $p->{'diagnosticcode'} =~ s/$re/ /g;
                    $p->{'diagnosticcode'} =  Sisimai::String->sweep($p->{'diagnosticcode'});
                }
            }
            $p->{'diagnostictype'} ||= 'X-UNIX'   if $p->{'reason'} eq 'mailererror';
            $p->{'diagnostictype'} ||= 'SMTP' unless $p->{'reason'} =~ /\A(?:feedback|vacation)\z/;

            # Check the value of SMTP command
            $p->{'smtpcommand'} = '' unless $p->{'smtpcommand'} =~ /\A(?:EHLO|HELO|MAIL|RCPT|DATA|QUIT)\z/;
        }

        CONSTRUCTOR: {
            # Create email address object
            my $as = Sisimai::Address->new($p->{'addresser'})                  || next RISEOF;
            my $ar = Sisimai::Address->new({ 'address' => $p->{'recipient'} }) || next RISEOF;
            my @ea = (qw|
                action deliverystatus diagnosticcode diagnostictype feedbacktype lhost listid
                messageid origin reason replycode rhost smtpagent smtpcommand subject 
            |);

            $o = {
                'addresser'      => $as,
                'recipient'      => $ar,
                'senderdomain'   => $as->host,
                'destination'    => $ar->host,
                'alias'          => $p->{'alias'} || $ar->alias,
                'token'          => Sisimai::String->token($as, $ar, $p->{'timestamp'}),
            };

            # Other accessors
            $o->{ $_ }           ||= $p->{ $_ }    // '' for @ea;
            $o->{'catch'}          = $p->{'catch'} // undef;
            $o->{'hardbounce'}     = int $p->{'hardbounce'};
            $o->{'replycode'}    ||= Sisimai::SMTP::Reply->find($p->{'diagnosticcode'}) || '';
            $o->{'timestamp'}      = gmtime Sisimai::Time->new($p->{'timestamp'});
            $o->{'timezoneoffset'} = $p->{'timezoneoffset'} // '+0000';
        }

        REASON: {
            # Decide the reason of email bounce
            if( $o->{'reason'} eq '' || exists $retryindex->{ $o->{'reason'} } ) {
                # The value of "reason" is empty or is needed to check with other values again
                my $r; my $de = $o->{'destination'};
                $r   = Sisimai::Rhost->get($o)      if Sisimai::Rhost->match($o->{'rhost'});
                $r ||= Sisimai::Rhost->get($o, $de) if Sisimai::Rhost->match($de);
                $r ||= Sisimai::Reason->get($o);
                $r ||= 'undefined';
                $o->{'reason'} = $r;
            }
        }

        HARD_BOUNCE: {
            # Set the value of "hardbounce", default value of "bouncebounce" is 0
            if( $o->{'reason'} =~ /\A(?:delivered|feedback|vacation)\z/ ) {
                # The value of "reason" is "delivered", "vacation" or "feedback".
                $o->{'replycode'} = '' unless $o->{'reason'} eq 'delivered';

            } else {
                my $smtperrors = $p->{'deliverystatus'}.' '.$p->{'diagnosticcode'};
                   $smtperrors = '' if $smtperrors =~ /\A\s+\z/;
                my $softorhard = Sisimai::SMTP::Error->soft_or_hard($o->{'reason'}, $smtperrors);
                $o->{'hardbounce'} = 1 if $softorhard eq 'hard';
            }
        }

        DELIVERYSTATUS: {
            # Set pseudo status code
            last DELIVERYSTATUS if $o->{'deliverystatus'};

            my $smtperrors = $o->{'replycode'}.' '.$p->{'diagnosticcode'};
               $smtperrors = '' if $smtperrors =~ /\A\s+\z/;
            my $permanent1 = Sisimai::SMTP::Error->is_permanent($smtperrors) // 1;
            $o->{'deliverystatus'} = Sisimai::SMTP::Status->code($o->{'reason'}, $permanent1 ? 0 : 1);
        }

        REPLYCODE: {
            # Check both of the first digit of "deliverystatus" and "replycode"
            my $d1 = substr($o->{'deliverystatus'}, 0, 1);
            my $r1 = substr($o->{'replycode'}, 0, 1);
            $o->{'replycode'} = '' unless $d1 eq $r1;

            unless( $o->{'action'} =~ $actionlist ) {
                if( my $ox = Sisimai::RFC1894->field('Action: '.$o->{'action'}) ) {
                    # Rewrite the value of "Action:" field to the valid value
                    #
                    #    The syntax for the action-field is:
                    #       action-field = "Action" ":" action-value
                    #       action-value = "failed" / "delayed" / "delivered" / "relayed" / "expanded"
                    $o->{'action'} = $ox->[2];
                }
            }
            $o->{'action'}   = 'delayed' if $o->{'reason'} eq 'expired';
            $o->{'action'} ||= 'failed'  if $d1 =~ /\A[45]/;
        }

        push @$listoffact, bless($o, __PACKAGE__);
    } # End of for(RISEOF)

    return $listoffact;
}

sub softbounce {
    # Emulate "softbounce" accessor for the backward compatible
    # @return   [Integer]
    warn ' ***warning: Sisimai::Fact->softbounce will be removed at v5.1.0. Use Sisimai::Fact->hardbounce instead';
    my $self = shift;
    return 0  if $self->hardbounce == 1;
    return -1 if $self->reason =~ /\A(?:delivered|feedback|vacation)\z/;
    return 1;
}

sub damn {
    # Convert from object to hash reference
    # @return   [Hash] Data in Hash reference
    my $self = shift;
    my $data = undef;
    state $stringdata = [qw|
        action alias catch deliverystatus destination diagnosticcode diagnostictype feedbacktype
        lhost listid messageid origin reason replycode rhost senderdomain smtpagent smtpcommand
        subject timezoneoffset token
    |];

    eval {
        my $v = {};
        $v->{ $_ }         = $self->$_ // '' for @$stringdata;
        $v->{'hardbounce'} = int $self->hardbounce;
        $v->{'addresser'}  = $self->addresser->address;
        $v->{'recipient'}  = $self->recipient->address;
        $v->{'timestamp'}  = $self->timestamp->epoch;
        $data = $v;
    };
    return $data;
}

sub dump {
    # Data dumper
    # @param    [String] type   Data format: json, yaml
    # @return   [String, undef] Dumped data or undef if the value of first
    #                           argument is neither "json" nor "yaml"
    my $self = shift;
    my $type = shift || 'json';
    return undef unless $type =~ /\A(?:json|yaml)\z/;

    my $referclass = 'Sisimai::Fact::'.uc($type);
    my $modulepath = 'Sisimai/Fact/'.uc($type).'.pm';

    require $modulepath;
    return $referclass->dump($self);
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Fact - Parsed data object

=head1 SYNOPSIS

    use Sisimai::Fact;
    my $args = { 'data' => 'entire-email-text-including-all-the-headers' };
    my $fact = Sisimai::Fact->rise($args);
    for my $e ( @$fact ) {
        print $e->reason;               # userunknown, mailboxfull, and so on.
        print $e->recipient->address;   # (Sisimai::Address) envelope recipient address
        print $e->bonced->ymd           # (Sisimai::Time) Date of bounce
    }

=head1 DESCRIPTION

Sisimai::Fact generate parsed data from Sisimai::Message object.

=head1 CLASS METHODS

=head2 C<B<rise(I<Hash>)>>

C<rise> generate parsed data and returns an array reference which are
including Sisimai::Fact objects.

    my $mail = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mail->read ) {
        my $fact = Sisimai::Fact->make('data' => $r);
        for my $e ( @$fact ) {
            print $e->reason;               # userunknown, mailboxfull, and so on.
            print $e->recipient->address;   # (Sisimai::Address) envelope recipient address
            print $e->timestamp->ymd        # (Sisimai::Time) Date of the email bounce
        }
    }

If you want to get bounce records which reason is "delivered", set "delivered"
option to rise() method like the following:

    my $fact = Sisimai::Fact->rise('data' => $r, 'delivered' => 1);

Beginning from v4.19.0, `hook` argument is available to callback user defined
method like the following codes:

    my $call = sub {
        my $argv = shift;
        my $fish = { 'x-mailer' => '' };

        if( $argv->{'message'} =~ /^X-Mailer:\s*(.+)$/m ) {
            $fish->{'x-mailer'} = $1;
        }

        return $fish;
    };
    my $fact = Sisimai::Fact->rise('data' => 'entire-email-text');
    for my $e ( @$fact ) {
        print $e->catch->{'x-mailer'};      # Apple Mail (2.1283)
    }

=head1 INSTANCE METHODS

=head2 C<B<damn()>>

C<damn> convert the object to a hash reference.

    my $hash = $self->damn;
    print $hash->{'recipient'}; # user@example.jp
    print $hash->{'timestamp'}; # 1393940000

=head1 PROPERTIES

Sisimai::Fact have the following properties:

=head2 C<action> (I<String>)

C<action> is the value of Action: field in a bounce email message such as
C<failed> or C<delayed>.

    Action: failed

=head2 C<addresser> (I<Sisimai::Address)>

C<addressser> is L<Sisimai::Address> object generated from the sender address.
When Sisimai::Fact object is dumped as JSON, this value converted to an email
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
field or C<expanded from "address"> string did not exist in a bounce message,
this value is empty.

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

=head2 C<origin> (I<Path to the original email file>)

C<origin> is the path to the original email file of the parsed results. When
the original email data were input from STDIN, the value is C<<STDIN>>, were
input from a variable, the value is C<<MEMORY>>. This accessor method has been
implemented at v4.25.6.

=head2 C<recipient> (I<Sisimai::Address)>

C<recipient> is L<Sisimai::Address> object generated from the recipient address.
When Sisimai::Fact object is dumped as JSON, this value converted to an email
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
site L<https://libsisimai.org/en/reason/>.

=head2 C<replycode> (I<Integer>)

C<replycode> is the value of SMTP reply code picked from the error message or
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
example, when the value is C<Sendmail>, Sisimai used L<Sisimai::Lhost::Sendmail>
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
character (non-ASCII character), such as MIME encoded Japanese or German and so
on, the value of subject in parsed data is encoded with UTF-8 again.

=head2 C<token> (I<String>)

C<token> is an identifier of each email-bounce. The token string is created from
the sender email address (addresser) and the recipient email address (recipient)
and the machine time of the date in a bounce message as an MD5 hash value.
The token value is generated at C<token()> method of L<Sisimai::String> class.

If you want to get the same token string at command line, try to run the
following command:

    % printf "\x02%s\x1e%s\x1e%d\x03" sender@example.jp recipient@example.org `date '+%s'` | md5
    714d72dfd972242ad04f8053267e7365

=head2 C<timestamp> (I<Sisimai::Time>)

C<timestamp> is the date which email has bounced as a L<Sisima::Time> (Child
class of Time::Piece) object. When Sisimai::Fact object is dumped as JSON, this
value will be converted to an UNIX machine time (32 bits integer).

    Arrival-Date: Thu, 29 Apr 2009 23:45:33 +0900

=head2 C<timezomeoffset> (I<String>)

C<timezoneoffset> is a time zone offset of a bounce email which its email has
bounced. The format of this value is String like C<+0900>, C<-0200>.
If Sisimai has failed to get a value of time zone offset, this value will be
set as C<+0000>.

=head1 SEE ALSO

L<https://libsisimai.org/en/data/>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2020 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

