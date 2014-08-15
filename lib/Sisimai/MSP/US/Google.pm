package Sisimai::MSP::US::Google;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'    => qr/[@]googlemail[.]com[>]?\z/,
    'begin'   => qr/Delivery to the following recipient/,
    'start'   => qr/Technical details of (?:permanent|temporary) failure:/,
    'error'   => qr/The error that the other server returned was:/,
    'rfc822'  => qr/\A----- Original message -----\z/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/Delivery[ ]Status[ ]Notification/,
};

my $RxErr = {
    'expired' => [
        qr/DNS Error: Could not contact DNS servers/,
        qr/Delivery to the following recipient has been delayed/,
        qr/The recipient server did not accept our requests to connect/,
    ],
    'hostunknown' => [
        qr/DNS Error: Domain name not found/,
        qr/DNS Error: DNS server returned answer with no data/,
    ],
};

my $StateTable = {
    # Technical details of permanent failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 500 Remote server does not support TLS (state 6).
    '6'  => { 'command' => 'MAIL', 'reason' => 'systemerror' },

    # http://www.google.td/support/forum/p/gmail/thread?tid=08a60ebf5db24f7b&hl=en
    # Technical details of permanent failure:
    # Google tried to deliver your message, but it was rejected by the recipient domain. 
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 535 SMTP AUTH failed with the remote server. (state 8).
    '8'  => { 'command' => 'AUTH', 'reason' => 'systemerror' },

    # http://www.google.co.nz/support/forum/p/gmail/thread?tid=45208164dbca9d24&hl=en
    # Technical details of temporary failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 454 454 TLS missing certificate: error:0200100D:system library:fopen:Permission denied (#4.3.0) (state 9).
    '9'  => { 'command' => 'AUTH', 'reason' => 'systemerror' },

    # http://www.google.com/support/forum/p/gmail/thread?tid=5cfab8c76ec88638&hl=en
    # Technical details of permanent failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 500 Remote server does not support SMTP Authenticated Relay (state 12). 
    '12' => { 'command' => 'AUTH', 'reason' => 'systemerror' },

    # Technical details of permanent failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was: 
    # 550 550 5.7.1 <****@gmail.com>... Access denied (state 13).
    '13' => { 'command' => 'EHLO', 'reason' => 'blocked' },

    # Technical details of permanent failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 550 550 5.1.1 <******@*********.**>... User Unknown (state 14).
    # 550 550 5.2.2 <*****@****.**>... Mailbox Full (state 14).
    # 
    '14' => { 'command' => 'RCPT', 'reason' => 'userunknown' },

    # http://www.google.cz/support/forum/p/gmail/thread?tid=7090cbfd111a24f9&hl=en
    # Technical details of permanent failure:
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 550 550 5.7.1 SPF unauthorized mail is prohibited. (state 15).
    # 554 554 Error: no valid recipients (state 15). 
    '15' => { 'command' => 'DATA', 'reason' => 'filtered' },

    # http://www.google.com/support/forum/p/Google%20Apps/thread?tid=0aac163bc9c65d8e&hl=en
    # Technical details of permanent failure:
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 550 550 <****@***.**> No such user here (state 17).
    # 550 550 #5.1.0 Address rejected ***@***.*** (state 17).
    '17' => { 'command' => 'DATA', 'reason' => 'filtered' },

    # Technical details of permanent failure: 
    # Google tried to deliver your message, but it was rejected by the recipient domain.
    # We recommend contacting the other email provider for further information about the
    # cause of this error. The error that the other server returned was:
    # 550 550 Unknown user *****@***.**.*** (state 18).
    '18' => { 'command' => 'DATA', 'reason' => 'filtered' },
};

sub version     { '4.0.0' }
sub description { 'Google Gmail' }
sub smtpagent   { 'US::Google' }
sub headerlist  { return [ 'X-Failed-Recipients' ] }

sub scan {
    # @Description  Detect an error from Google Gmail
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    # Google Mail
    # From: Mail Delivery Subsystem <mailer-daemon@googlemail.com>
    # Received: from vw-in-f109.1e100.net [74.125.113.109] by ...
    #
    # * Check the body part
    #   This is an automatically generated Delivery Status Notification
    #   Delivery to the following recipient failed permanently:
    #
    #        recipient-address-here@example.jp
    #
    #   Technical details of permanent failure: 
    #   Google tried to deliver your message, but it was rejected by the
    #   recipient domain. We recommend contacting the other email provider
    #   for further information about the cause of this error. The error
    #   that the other server returned was: 
    #   550 550 <recipient-address-heare@example.jp>: User unknown (state 14).
    #
    #   -- OR --
    #   THIS IS A WARNING MESSAGE ONLY.
    #   
    #   YOU DO NOT NEED TO RESEND YOUR MESSAGE.
    #   
    #   Delivery to the following recipient has been delayed:
    #   
    #        mailboxfull@example.jp
    #   
    #   Message will be retried for 2 more day(s)
    #   
    #   Technical details of temporary failure:
    #   Google tried to deliver your message, but it was rejected by the recipient
    #   domain. We recommend contacting the other email provider for further infor-
    #   mation about the cause of this error. The error that the other server re-
    #   turned was: 450 450 4.2.2 <mailboxfull@example.jp>... Mailbox Full (state 14).
    #
    #   -- OR --
    #
    #   Delivery to the following recipient failed permanently:
    #   
    #        userunknown@example.jp
    #   
    #   Technical details of permanent failure:=20
    #   Google tried to deliver your message, but it was rejected by the server for=
    #    the recipient domain example.jp by mx.example.jp. [192.0.2.59].
    #   
    #   The error that the other server returned was:
    #   550 5.1.1 <userunknown@example.jp>... User Unknown
    #
    return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};
    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $softbounce = 0;     # (Integer) 1 = Soft bounce
    my $statecode0 = 0;     # (Integer) The value of (state *) in the error message

    my $v = undef;
    my $p = undef;
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::RFC5322;
    require Sisimai::Address;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
        $e =~ s{=\d+\z}{};

        if( ( $e =~ $RxMSP->{'rfc822'} ) .. ( $e =~ $RxMSP->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                # Skip if DKIM-Signature header
                next if $e =~ m/\ADKIM-Signature[:]/;

                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;

                $previousfn = '';
                next unless grep { lc( $lhs ) eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxMSP->{'begin'} ) .. ( $e =~ $RxMSP->{'rfc822'} );
            next unless length $e;

            # Technical details of permanent failure:=20
            # Google tried to deliver your message, but it was rejected by the recipient =
            # domain. We recommend contacting the other email provider for further inform=
            # ation about the cause of this error. The error that the other server return=
            # ed was: 554 554 5.7.0 Header error (state 18).
            #
            # -- OR --
            #
            # Technical details of permanent failure:=20
            # Google tried to deliver your message, but it was rejected by the server for=
            # the recipient domain example.jp by mx.example.jp. [192.0.2.49].
            #
            # The error that the other server returned was:
            # 550 5.1.1 <userunknown@example.jp>... User Unknown
            #
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A\s+([^ ]+[@][^ ]+)\z/ ) {
                # kijitora@example.jp: 550 5.2.2 <kijitora@example>... Mailbox Full
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }

                my $r = Sisimai::Address->s3s4( $1 );
                if( Sisimai::RFC5322->is_emailaddress( $r ) ) {
                    $v->{'recipient'} = $r;
                    $recipients++;
                }

            } else {
                if( $e =~ m/Technical details of (.+) failure:/ ) {
                    # Technical details of permanent failure: 
                    # Technical details of temporary failure: 
                    $softbounce = 1 unless $1 eq 'permanenet';
                }

                if( $e =~ m/=\z/ ) {
                    # Google tried to deliver your message, but it was rejected by the recipient =
                    # domain. We recommend contacting the other email provider for further inform=
                    $e =~ s{=\z}{};
                    $v->{'diagnosis'} .= $e;

                } else {
                    # No "=" character at the end of the line
                    $v->{'diagnosis'} .= $e.' ';
                }
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = undef;
    }

    return undef unless $recipients;
    require Sisimai::RFC3463;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'date'}    ||= $mhead->{'date'};
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;

        chomp $e->{'diagnosis'};
        $e->{'diagnosis'} =~ y{ }{}s;
        $e->{'diagnosis'} =~ s{\A }{}g;
        $e->{'diagnosis'} =~ s{ \z}{}g;
        $e->{'diagnosis'} =~ s{ [-]{2,}.+\z}{};

        unless( $e->{'rhost'} ) {
            # Get the value of remote host
            if( $e->{'diagnosis'} =~ m/\s+by\s+([^ ]+)[.]\s+\[(\d+[.]\d+[.]\d+[.]\d+)\][.]/ ) {
                # Google tried to deliver your message, but it was rejected by # the server 
                # for the recipient domain example.jp by mx.example.jp. [192.0.2.153].
                my $x = $1;
                my $y = $2;
                if( $x =~ m/[-0-9a-zA-Z]+[.][a-zA-Z]+\z/ ) {
                    # Maybe valid hostname
                    $e->{'rhost'} = $x;
                } else {
                    # Use IP address instead
                    $e->{'rhost'} = $y;
                }
            }
        }

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $statecode0 = $1 if( $e->{'diagnosis'} =~ m/[(]state[ ](\d+)[)][.]/ );
        if( exists $StateTable->{ $statecode0 } ) {
            # (state *)
            $e->{'reason'}  = $StateTable->{ $statecode0 }->{'reason'};
            $e->{'command'} = $StateTable->{ $statecode0 }->{'command'};

        } else {

            SESSION: for my $r ( keys %$RxErr ) {
                # Verify each regular expression of session errors
                PATTERN: for my $rr ( @{ $RxErr->{ $r } } ) {
                    # Check each regular expression
                    next(PATTERN) unless $e->{'diagnosis'} =~ $rr;
                    $e->{'reason'} = $r;
                    last(SESSION);
                }
            }
        }

        $e->{'status'} = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        STATUS_CODE: while(1) {
            last if length $e->{'status'};

            if( $e->{'reason'} ) {
                # Set pseudo status code
                $softbounce = 1 if Sisimai::RFC3463->is_softbounce( $e->{'diagnosis'} );
                my $s = $softbounce ? 't' : 'p';
                my $r = Sisimai::RFC3463->status( $e->{'reason'}, $s, 'i' );
                $e->{'status'} = $r if length $r;
            }

            $e->{'status'} ||= $softbounce ? '4.0.0' : '5.0.0';
            last;
        }

        $e->{'spec'} = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;
        $e->{'command'} ||= 'CONN';

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Google - bounce mail parser class for Gmail.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Google;

=head1 DESCRIPTION

Sisimai::MSP::US::Google parses a bounce email which created by Gmail.  Methods
in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::US::Google->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::Google->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::Google->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
