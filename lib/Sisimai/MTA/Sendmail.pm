package Sisimai::MTA::Sendmail;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# Error text regular expressions which defined in sendmail/savemail.c
#   savemail.c:1040|if (printheader && !putline("   ----- Transcript of session follows -----\n",
#   savemail.c:1041|          mci))
#   savemail.c:1042|  goto writeerr;
#
my $RxMTA = {
    'from'    => qr/\AMail Delivery Subsystem/,
    'begin'   => qr/\A\s+[-]+ Transcript of session follows [-]+\z/,
    'error'   => qr/\A[.]+ while talking to .+[:]\z/,
    'rfc822'  => qr{\AContent-Type:[ ]*(?:message/rfc822|text/rfc822-headers)\z},
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/(?:see transcript for details\z|\AWarning: )/,
};

sub description { 'V8Sendmail: /usr/sbin/sendmail' }
sub smtpagent   { 'Sendmail' }

sub scan {
    # @Description  Detect an error from Sendmail
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};
    unless( $mhead->{'subject'} =~ m/\A\s*Fwd?:/i ) {
        # Fwd: Returned mail: see transcript for details
        # Do not execute this code if the bounce mail is a forwarded message.
        return undef unless $mhead->{'from'} =~ $RxMTA->{'from'};
    }

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $esmtpreply = '';    # (String) Reply from remote server on SMTP session
    my $sessionerr = 0;     # (Integer) Flag, 1 if it is SMTP session error
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'date'  => '',      # The value of Arrival-Date header
        'rhost' => '',      # The value of Reporting-MTA header
    };
    my $anotherset = {};    # Another error information

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
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
            next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Final-Recipient: RFC822; userunknown@example.jp
                # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                # Action: failed
                # Status: 5.1.1
                # Remote-MTA: DNS; mx.example.jp
                # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # Final-Recipient: RFC822; userunknown@example.jp
                    if( length $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[ -1 ];
                    }
                    $v->{'recipient'} = $1;
                    $recipients++;

                } elsif( $e =~ m/\A[Xx]-[Aa]ctual-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # X-Actual-Recipient: RFC822; kijitora@example.co.jp
                    $v->{'alias'} = $1;

                } elsif( $e =~ m/\A[Aa]ction:[ ]*(.+)\z/ ) {
                    # Action: failed
                    $v->{'action'} = lc $1;

                } elsif( $e =~ m/\A[Ss]tatus:[ ]*(\d[.]\d+[.]\d+)/ ) {
                    # Status: 5.1.1
                    # Status:5.2.0
                    # Status: 5.1.0 (permanent failure)
                    $v->{'status'} = $1;

                } elsif( $e =~ m/\A[Rr]emote-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Remote-MTA: DNS; mx.example.jp
                    $v->{'rhost'} = lc $1;

                } elsif( $e =~ m/\A[Ll]ast-[Aa]ttempt-[Dd]ate:[ ]*(.+)\z/ ) {
                    # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
                    $v->{'date'} = $1;

                } else {

                    if( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;

                    } elsif( $p =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*/ && $e =~ m/\A[\s\t]+(.+)\z/ ) {
                        # Continued line of the value of Diagnostic-Code header
                        $v->{'diagnosis'} .= ' '.$1;
                        $e = 'Diagnostic-Code: '.$e;
                    }
                }

            } else {
                # ----- Transcript of session follows -----
                # ... while talking to mta.example.org.:
                # >>> DATA
                # <<< 550 Unknown user recipient@example.jp
                # 554 5.0.0 Service unavailable
                # ...
                # Reporting-MTA: dns; mx.example.jp
                # Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
                # Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
                if( $e =~ m/\A[>]{3}[ ]+([A-Z]{4})[ ]?/ ) {
                    # >>> DATA
                    $commandtxt = $1;

                } elsif( $e =~ m/\A[<]{3}[ ]+(.+)\z/ ) {
                    # <<< Response
                    $esmtpreply = $1;

                } elsif( $e =~ m/\A[Rr]eporting-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if length $connheader->{'rhost'};
                    $connheader->{'rhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A[Rr]eceived-[Ff]rom-MTA:[ ]*(?:DNS|dns);[ ]*(.+)\z/ ) {
                    # Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
                    next if( exists $connheader->{'lhost'} && length $connheader->{'lhost'} );

                    # The value of "lhost" is optional
                    $connheader->{'lhost'} = $1;
                    $connvalues++;

                } elsif( $e =~ m/\A[Aa]rrival-[Dd]ate:[ ]*(.+)\z/ ) {
                    # Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
                    next if length $connheader->{'date'};
                    $connheader->{'date'} = $1;
                    $connvalues++;

                } else {
                    # Detect SMTP session error or connection error
                    next if $sessionerr;
                    if( $e =~ $RxMTA->{'error'} ) { 
                      # ----- Transcript of session follows -----
                       # ... while talking to mta.example.org.:
                       $sessionerr = 1;
                       next;
                    }

                    if( $e =~ m/\A[<](.+)[>][.]+ (.+)\z/ ) {
                        # <kijitora@example.co.jp>... Deferred: Name server: example.co.jp.: host name lookup failure
                        $anotherset->{'recipient'} = $1;
                        $anotherset->{'diagnosis'} = $2;

                    } else {
                        # ----- Transcript of session follows -----
                        # Message could not be delivered for too long
                        # Message will be deleted from queue
                        next if $e =~ m/\A\s*[-]+/;
                        if( $e =~ m/\A[45]\d\d\s([45][.]\d[.]\d)\s.+/ ) {
                            # 550 5.1.2 <kijitora@example.org>... Message
                            #
                            # DBI connect('dbname=...')
                            # 554 5.3.0 unknown mailer error 255
                            $anotherset->{'status'} = $1;
                            $anotherset->{'diagnosis'} .= ' '.$e;

                        } elsif( $e =~ m/\A(?:Message|Warning:) / ) {
                            # Message could not be delivered for too long
                            # Warning: message still undelivered after 4 hours
                            $anotherset->{'diagnosis'} .= ' '.$e;
                        }
                    }
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
        $e->{'command'} ||= $commandtxt || '';
        $e->{'command'} ||= 'EHLO' if length $esmtpreply;

        if( exists $anotherset->{'diagnosis'} && length $anotherset->{'diagnosis'} ) {
            # Copy alternative error message
            $e->{'diagnosis'}   = $anotherset->{'diagnosis'} if $e->{'diagnosis'} =~ m/\A\s+\z/;
            $e->{'diagnosis'} ||= $anotherset->{'diagnosis'};

            if( $e->{'diagnosis'} =~ m/\A\d+\z/ ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $anotherset->{'diagnosis'};
            }
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( exists $anotherset->{'status'} && length $anotherset->{'status'} ) {
            # Check alternative status code
            if( ! $e->{'status'} || $e->{'status'} !~ m/\A[45][.]\d[.]\d\z/ ) {
                # Override alternative status code
                $e->{'status'} = $anotherset->{'status'};
            }
        }

        unless( $e->{'recipient'} =~ m/\A[^ ]+[@][^ ]+\z/ ) {
            # @example.jp, no local part
            if( $e->{'diagnosis'} =~ m/[<]([^ ]+[@][^ ]+)[>]/ ) {
                # Get email address from the value of Diagnostic-Code header
                $e->{'recipient'} = $1;
            }
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Sendmail - bounce mail parser class for v8 Sendmail.

=head1 SYNOPSIS

    use Sisimai::MTA::Sendmail;

=head1 DESCRIPTION

Sisimai::MTA::Sendmail parses a bounce email which created by v8 Sendmail.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Sendmail->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Sendmail->smtpagent;

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
