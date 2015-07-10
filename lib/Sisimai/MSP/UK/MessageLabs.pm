package Sisimai::MSP::UK::MessageLabs;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $RxMSP = {
    'from'    => qr/MAILER-DAEMON[@]messagelabs[.]com/,
    'begin'   => qr|\AContent-Type: message/delivery-status|,
    'error'   => qr/\AReason:\s*(.+)\z/,
    'rfc822'  => qr|\AContent-Type: text/rfc822-headers\z|,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\AMail Delivery Failure/,
};

my $RxErr = {
    'userunknown' => qr/No[ ]such[ ]user/x,
};

sub version     { '4.0.5' }
sub description { 'Symantec.cloud http://www.messagelabs.com' }
sub smtpagent   { 'UK::MessageLabs' }
sub headerlist  { return [ 'X-Msg-Ref', 'X-Originating-IP' ] }

sub scan {
    # @Description  Detect an error from MessageLabs.com
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'from'}    =~ $RxMSP->{'from'};
    return undef unless $mhead->{'subject'} =~ $RxMSP->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'  => '',      # The value of Arrival-Date header
        'lhost' => '',      # The value of Reporting-MTA header
    };

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMSP->{'begin'} and $RxMSP->{'rfc822'}.
        if( ( $e =~ $RxMSP->{'rfc822'} ) .. ( $e =~ $RxMSP->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $whs = lc $lhs;

                $previousfn = '';
                next unless grep { $whs eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ lc $previousfn };
                $rfc822part .= $e."\n" if grep { $previousfn eq $_ } @$longfields;

            } else {
                # Check the end of headers in rfc822 part
                next unless grep { $previousfn eq $_ } @$longfields;
                next if length $e;
                $rfc822next->{ lc $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxMSP->{'begin'} ) .. ( $e =~ $RxMSP->{'rfc822'} );
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # This is the mail delivery agent at messagelabs.com.
                # 
                # I was unable to deliver your message to the following addresses:
                # 
                # maria@dest.example.net
                # 
                # Reason: 550 maria@dest.example.net... No such user
                # 
                # The message subject was: Re: BOAS FESTAS!
                # The message date was: Tue, 23 Dec 2014 20:39:24 +0000
                # The message identifier was: DB/3F-17375-60D39495
                # The message reference was: server-5.tower-143.messagelabs.com!1419367172!32=
                # 691968!1
                # 
                # Please do not reply to this email as it is sent from an unattended mailbox.
                # Please visit www.messagelabs.com/support for more details
                # about this error message and instructions to resolve this issue.
                # 
                # 
                # --b0Nvs+XKfKLLRaP/Qo8jZhQPoiqeWi3KWPXMgw==
                # Content-Type: message/delivery-status
                # 
                # Reporting-MTA: dns; server-15.bemta-3.messagelabs.com
                # Arrival-Date: Tue, 23 Dec 2014 20:39:34 +0000
                # 
                # Action: failed
                # Status: 5.0.0
                # Last-Attempt-Date: Tue, 23 Dec 2014 20:39:35 +0000
                # Remote-MTA: dns; mail.dest.example.net
                # Diagnostic-Code: smtp; 550 maria@dest.example.net... No such user
                # Final-Recipient: rfc822; maria@dest.example.net
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # Final-Recipient: rfc822; maria@dest.example.net
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $recipients++;

                } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                    # Action: failed
                    $v->{'action'} = lc $1;

                } elsif( $e =~ m/\A[Ss]tatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                    # Status: 5.0.0
                    $v->{'status'} = $1;

                } else {

                    if( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                        # Diagnostic-Code: smtp; 550 maria@dest.example.net... No such user
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                    } elsif( $p =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*/ && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                # Reporting-MTA: dns; server-15.bemta-3.messagelabs.com
                # Arrival-Date: Tue, 23 Dec 2014 20:39:34 +0000
                if( $e =~ m/\A[Rr]eporting-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Reporting-MTA: dns; server-15.bemta-3.messagelabs.com
                    next if length $connheader->{'lhost'};
                    $connheader->{'lhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A[Aa]rrival-[Dd]ate:[ ]*(.+)\z/ ) {
                    # Arrival-Date: Tue, 23 Dec 2014 20:39:34 +0000
                    next if length $connheader->{'date'};
                    $connheader->{'date'} = $1;
                    $connvalues++;
                }
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        map { $e->{ $_ } ||= $connheader->{ $_ } || '' } keys %$connheader;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'spec'}    ||= 'SMTP';
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        SESSION: for my $r ( keys %$RxErr ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $RxErr->{ $r };
            $e->{'reason'} = $r;
            last;
        }

        if( length( $e->{'status'} ) == 0 || $e->{'status'} =~ m/\A\d[.]0[.]0\z/ ) {
            # There is no value of Status header or the value is 5.0.0, 4.0.0
            my $r = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
            $e->{'status'} = $r if length $r;
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::UK::MessageLabs - bounce mail parser class for C<MessageLabs>.

=head1 SYNOPSIS

    use Sisimai::MSP::UK::MessageLabs;

=head1 DESCRIPTION

Sisimai::MSP::UK::MessageLabs parses a bounce email which created by 
Symantec.cloud: formerly MessageLabs. Methods in the module are called from only
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MSP::UK::MessageLabs->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::UK::MessageLabs->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MSP name.

    print Sisimai::MSP::UK::MessageLabs->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

