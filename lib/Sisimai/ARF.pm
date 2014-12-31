package Sisimai::ARF;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::MTA;

# http://tools.ietf.org/html/rfc5965
# http://en.wikipedia.org/wiki/Feedback_loop_(email)
# http://en.wikipedia.org/wiki/Abuse_Reporting_Format
my $RxARF = {
    'content-type' => qr/report-type=["]?feedback-report["]?/,
    'begin'        => qr/\AThis is .+ email abuse report/,
    'rfc822'       => qr|\AContent-Type: message/rfc822|,
    'endof'        => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

sub version     { return '4.0.3' }
sub description { return 'Abuse Feedback Reporting Format' }
sub headerlist  { return [] }

sub DELIVERYSTATUS { return Sisimai::MTA->DELIVERYSTATUS }
sub RFC822HEADERS  { 
    my $class = shift;
    my $argvs = shift;
    return Sisimai::MTA->RFC822HEADERS( $argvs );
}

sub is_arf {
    # @Description  Email is a Feedback-Loop message or not
    # @Param <str>  (String) The value of "Content-Type" header
    # @Return       (Integer) 1 = Feedback Loop, 0 is not.
    my $class = shift;
    my $argvs = shift || return 0;

    return 1 if $argvs =~ $RxARF->{'content-type'};
    return 0;
}

sub scan {
    # @Description  Detect an error for FeedBack Loop
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'content-type'} =~ $RxARF->{'content-type'};
    # return undef unless $mhead->{'from'}    =~ $RxARF->{'from'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $rcptintext = '';    # (String) Recipient address in the message body
    my $remotename = '';    # (String) The value of "Reporting-MTA"
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $commondata = {
        'diagnosis'    => '',   # Error message
        'from'         => '',   # Original-Mail-From:
        'rhost'        => '',   # Reporting-MTA:
    };
    my $arfheaders = {
        'feedbacktype' => '',   # FeedBack-Type:
        'rhost'        => '',   # Source-IP:
        'agent'        => '',   # User-Agent:
        'date'         => '',   # Arrival-Date:
    };

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    require Sisimai::Address;
    # 3.1.  Required Fields
    #
    #   The following report header fields MUST appear exactly once:
    #
    #   o  "Feedback-Type" contains the type of feedback report (as defined
    #      in the corresponding IANA registry and later in this memo).  This
    #      is intended to let report parsers distinguish among different
    #      types of reports.
    #
    #   o  "User-Agent" indicates the name and version of the software
    #      program that generated the report.  The format of this field MUST
    #      follow section 14.43 of [HTTP].  This field is for documentation
    #      only; there is no registry of user agent names or versions, and
    #      report receivers SHOULD NOT expect user agent names to belong to a
    #      known set.
    #
    #   o  "Version" indicates the version of specification that the report
    #      generator is using to generate the report.  The version number in
    #      this specification is set to "1".
    #
    for my $e ( @$stripedtxt ) {
        # Read each line between $RxARF->{'begin'} and $RxARF->{'rfc822'}.
        if( ( $e =~ $RxARF->{'rfc822'} ) .. ( $e =~ $RxARF->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;

                $previousfn = '';
                next unless grep { lc( $lhs ) eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";
                $rcptintext  = $rhs if $lhs eq 'To';

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;
                $rcptintext .= $e if $previousfn eq 'To';
            }

        } else {
            # Before "message/rfc822"
            next unless ( $e =~ $RxARF->{'begin'} ) .. ( $e =~ $RxARF->{'rfc822'} );
            next unless length $e;

            # Feedback-Type: abuse
            # User-Agent: SomeGenerator/1.0
            # Version: 0.1
            # Original-Mail-From: <somespammer@example.net>
            # Original-Rcpt-To: <kijitora@example.jp>
            # Received-Date: Thu, 29 Apr 2009 00:00:00 JST
            # Source-IP: 192.0.2.1
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\AOriginal-Rcpt-To:\s+[<]?(.+)[>]?\z/ ||
                $e =~ m/\ARedacted-Address:\s([^ ].+[@])\z/ ) {
                # Original-Rcpt-To header field is optional and may appear any
                # number of times as appropriate:
                # Original-Rcpt-To: <user@example.com>
                # Redacted-Address: localpart@
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = Sisimai::Address->s3s4( $1 );
                $recipients++;

            } elsif( $e =~ m/\AFeedback-Type:\s*([^ ]+)\z/ ) {
                # The header field MUST appear exactly once.
                # Feedback-Type: abuse
                $arfheaders->{'feedbacktype'} = $1;

            } elsif( $e =~ m/\AUser-Agent:\s*(.+)\z/ ) {
                # The header field MUST appear exactly once.
                # User-Agent: SomeGenerator/1.0
                $arfheaders->{'agent'} = $1;

            } elsif( $e =~ m/\A(?:Received|Arrival)-Date:\s*(.+)\z/ ) {
                # Arrival-Date header is optional and MUST NOT appear more than
                # once.
                # Received-Date: Thu, 29 Apr 2010 00:00:00 JST
                # Arrival-Date: Thu, 29 Apr 2010 00:00:00 +0000
                $arfheaders->{'date'} = $1;

            } elsif( $e =~ m/\AReporting-MTA:[ ]*dns;[ ]*(.+)\z/ ) {
                # The header is optional and MUST NOT appear more than once.
                # Reporting-MTA: dns; mx.example.jp
                $commondata->{'rhost'} = $1;

            } elsif( $e =~ m/\ASource-IP:\s*(.+)\z/ ) {
                # The header is optional and MUST NOT appear more than once.
                # Source-IP: 192.0.2.45
                $arfheaders->{'rhost'} = $1;

            } elsif( $e =~ m/\AOriginal-Mail-From:\s*(.+)\z/ ) {
                # the header is optional and MUST NOT appear more than once.
                # Original-Mail-From: <somespammer@example.net>
                $commondata->{'from'} ||= Sisimai::Address->s3s4( $1 );

            } elsif( $e =~ $RxARF->{'begin'} ) {
                # This is an email abuse report for an email message with the 
                #   message-id of 0000-000000000000000000000000000000000@mx 
                #   received from IP address 192.0.2.1 on 
                #   Thu, 29 Apr 2010 00:00:00 +0900 (JST)
                $commondata->{'diagnosis'} = $e;
            }

        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    return undef unless $recipients;
    require Sisimai::RFC5322;

    unless( $rfc822part =~ m/\bFrom: [^ ]+[@][^ ]+\b/ ) {
        # From: header in the original message
        if( length $commondata->{'from'} ) {

            $rfc822part .= sprintf( "From: %s\n", $commondata->{'from'} );
        }
    }

    for my $e ( @$dscontents ) {

        if( $e->{'recipient'} =~ m/\A[^ ]+[@]\z/ ) {
            # AOL = http://forums.cpanel.net/f43/aol-brutal-work-71473.html
            $e->{'recipient'} = Sisimai::Address->s3s4( $rcptintext );
        }
        map {  $e->{ $_ } ||= $arfheaders->{ $_ } } keys %$arfheaders;
        $e->{'diagnosis'} ||= $commondata->{'diagnosis'};

        unless( $e->{'rhost'} ) {
            # Get the remote IP address from the message body
            if( length $commondata->{'rhost'} ) {
                # The value of "Reporting-MTA" header
                $e->{'rhost'} = $commondata->{'rhost'};

            } elsif( $e->{'diagnosis'} =~ m/\breceived from IP address ([^ ]+)/ ) {
                # This is an email abuse report for an email message received
                # from IP address 24.64.1.1 on Thu, 29 Apr 2010 00:00:00 +0000
                $e->{'rhost'} = $1;
            }
        }

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'spec'}    = 'SMTP';
        $e->{'action'}  = 'failed';
        $e->{'reason'}  = 'feedback';
        $e->{'command'} = '';
        $e->{'agent'} ||= 'FeedBack-Loop';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::ARF - Parser class for detecting ARF: Abuse Feedback Reporting Format.

=head1 SYNOPSIS

Do not use this class directly, use Sisimai::ARF.

    use Sisimai::ARF;
    my $v = Sisimai::ARF->scan( $header, $body );

=head1 DESCRIPTION

Sisimai::ARF is a parser for email returned as a FeedBack Loop report message.

=head1 FEEDBACK TYPES

=head2 B<abuse>

Unsolicited email or some other kind of email abuse.

=head2 B<fraud>

Indicates some kind of C<fraud> or C<phishing> activity.

=head2 B<other>

Any other feedback that does not fit into other registered types.

=head2 B<virus>

Report of a virus found in the originating message.

=head1 SEE ALSO

L<http://tools.ietf.org/html/rfc5965>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
