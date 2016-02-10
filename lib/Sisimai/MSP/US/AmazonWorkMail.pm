package Sisimai::MSP::US::AmazonWorkMail;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

# https://aws.amazon.com/workmail/
my $Re0 = {
    'subject' => qr/Delivery[_ ]Status[_ ]Notification[_ ].+Failure/,
    'received'=> qr/.+[.]smtp-out[.].+[.]amazonses[.]com\b/,
    'x-mailer'=> qr/\AAmazon WorkMail\z/,
};
my $Re1 = {
    'begin'   => qr/\ATechnical report:\z/,
    'rfc822'  => qr|\Acontent-type: message/rfc822\z|,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'Amazon WorkMail: https://aws.amazon.com/workmail/' }
sub smtpagent   { 'US::AmazonWorkMail' }

# X-Mailer: Amazon WorkMail
# X-Original-Mailer: Amazon WorkMail
# X-Ses-Outgoing: 2016.01.14-54.240.27.159
sub headerlist  { return [ 'X-SES-Outgoing', 'X-Original-Mailer' ] }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from Amazon WorkMail
    # @param         [Hash] mhead       Message header of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.1.29
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;
    my $xmail = $mhead->{'x-original-mailer'} || $mhead->{'x-mailer'} || '';

    $match++ if $mhead->{'x-ses-outgoing'};
    if( $xmail ) {
        # X-Mailer: Amazon WorkMail
        # X-Original-Mailer: Amazon WorkMail
        $match++ if $xmail =~ $Re0->{'x-mailer'};
    }
    return undef if $match < 2;

    if( $$mbody =~ /^Content-Transfer-Encoding: quoted-printable$/m ) {
        # This is a multi-part message in MIME format. Your mail reader does not
        # understand MIME message format.
        # --=_gy7C4Gpes0RP4V5Bs9cK4o2Us2ZT57b-3OLnRN+4klS8dTmQ
        # Content-Type: text/plain; charset=iso-8859-15
        # Content-Transfer-Encoding: quoted-printable
        require Sisimai::MIME;
        $$mbody = Sisimai::MIME->qprintd( $mbody );
    }

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $connvalues = 0;     # (Integer) Flag, 1 if all the value of $connheader have been set
    my $connheader = {
        'lhost' => '',      # The value of Reporting-MTA header
    };
    my $v = undef;

    for my $e ( @hasdivided ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $Re1->{'begin'} ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $Re1->{'rfc822'} ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = lc $1;
                $previousfn = '';
                next unless exists $RFC822Head->{ $lhs };

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[ \t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ $previousfn };
                $rfc822part .= $e."\n" if exists $LongFields->{ $previousfn };

            } else {
                # Check the end of headers in rfc822 part
                next unless exists $LongFields->{ $previousfn };
                next if length $e;
                $rfc822next->{ $previousfn } = 1;
            }
        } else {
            # Before "message/rfc822"
            next unless $readcursor & $Indicators->{'deliverystatus'};
            next unless length $e;

            if( $connvalues == scalar( keys %$connheader ) ) {
                # Action: failed
                # Final-Recipient: rfc822; kijitora@libsisimai.org
                # Diagnostic-Code: smtp; 554 4.4.7 Message expired: unable to deliver in 840 minutes.<421 4.4.2 Connection timed out>
                # Status: 4.4.7
                $v = $dscontents->[ -1 ];

                if( $e =~ m/\A[Ff]inal-[Rr]ecipient:[ ]*(?:RFC|rfc)822;[ ]*([^ ]+)\z/ ) {
                    # Final-Recipient: RFC822; kijitora@example.jp
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
                    # Status: 5.1.1
                    $v->{'status'} = $1;

                } else {
                    if( $e =~ m/\A[Dd]iagnostic-[Cc]ode:[ ]*(.+?);[ ]*(.+)\z/ ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <kijitora@example.jp>... User Unknown
                        $v->{'spec'} = uc $1;
                        $v->{'diagnosis'} = $2;
                    }
                }
            } else {
                # Technical report:
                #
                # Reporting-MTA: dsn; a27-85.smtp-out.us-west-2.amazonses.com
                #
                if( $e =~ m/\A[Rr]eporting-MTA:[ ]*[DNSdns]+;[ ]*(.+)\z/ ) {
                    # Reporting-MTA: dns; mx.example.jp
                    next if length $connheader->{'lhost'};
                    $connheader->{'lhost'} = lc $1;
                    $connvalues++;
                }
            }

            # <!DOCTYPE HTML><html>
            # <head>
            # <meta name="Generator" content="Amazon WorkMail v3.0-2023.77">
            # <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            last if $e =~ m/\A[<]!DOCTYPE HTML[>][<]html[>]\z/;

        } # End of if: rfc822
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::SMTP::Status;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        map { $e->{ $_ } ||= $connheader->{ $_ } || '' } keys %$connheader;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r0 = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r0->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r0->[-1] ) };
        }
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        if( $e->{'status'} =~ m/\A[45][.][01][.]0\z/ ) {
            # Get other D.S.N. value from the error message
            my $pseudostatus = '';
            my $errormessage = $e->{'diagnosis'};

            if( $e->{'diagnosis'} =~ m/["'](\d[.]\d[.]\d.+)['"]/ ) {
                # 5.1.0 - Unknown address error 550-'5.7.1 ...
                $errormessage = $1;
            }

            $pseudostatus = Sisimai::SMTP::Status->find( $errormessage );
            $e->{'status'} = $pseudostatus if length $pseudostatus;
        }

        $e->{'reason'} ||= Sisimai::SMTP::Status->name( $e->{'status'} );
        $e->{'spec'}   ||= 'SMTP';
        $e->{'agent'}    = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::AmazonWorkMail - bounce mail parser class for C<Amazon WorkMail>.

=head1 SYNOPSIS

    use Sisimai::MSP::US::AmazonWorkMail;

=head1 DESCRIPTION

Sisimai::MSP::US::AmazonWorkMail parses a bounce email which created by C<Amazon
WorkMail>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::AmazonWorkMail->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::AmazonWorkMail->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

