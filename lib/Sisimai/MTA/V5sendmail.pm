package Sisimai::MTA::V5sendmail;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

# Error text regular expressions which defined in src/savemail.c
#   savemail.c:485| (void) fflush(stdout);
#   savemail.c:486| p = queuename(e->e_parent, 'x');
#   savemail.c:487| if ((xfile = fopen(p, "r")) == NULL)
#   savemail.c:488| {
#   savemail.c:489|   syserr("Cannot open %s", p);
#   savemail.c:490|   fprintf(fp, "  ----- Transcript of session is unavailable -----\n");
#   savemail.c:491| }
#   savemail.c:492| else
#   savemail.c:493| {
#   savemail.c:494|   fprintf(fp, "   ----- Transcript of session follows -----\n");
#   savemail.c:495|   if (e->e_xfp != NULL)
#   savemail.c:496|       (void) fflush(e->e_xfp);
#   savemail.c:497|   while (fgets(buf, sizeof buf, xfile) != NULL)
#   savemail.c:498|       putline(buf, fp, m);
#   savemail.c:499|   (void) fclose(xfile);
my $RxMTA = {
    'from'    => qr/\AMail Delivery Subsystem/,
    'begin'   => qr/\A\s+[-]+ Transcript of session follows [-]+\z/,
    'error'   => qr/\A[.]+ while talking to .+[:]\z/,
    'rfc822'  => [
        qr/\A\s+----- Unsent message follows -----/,
        qr/\A\s+----- No message was collected -----/,
    ],
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/\AReturned mail: [A-Z]/,
};

sub version     { '4.0.2' }
sub description { 'Sendmail version 5' }
sub smtpagent   { 'V5sendmail' }

sub scan {
    # @Description  Detect an error from V5sendmail
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $responding = [];    # (Ref->Array) Responses from remote server
    my $commandset = [];    # (Ref->Array) SMTP command which is sent to remote server
    my $anotherset = {};    # Another error information

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        $match = 1 if grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} };

        if( ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;

                $previousfn = '';
                next unless grep { lc( $lhs ) eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ lc $previousfn };
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;

            } else {
                # Check the end of headers in rfc822 part
                next unless $previousfn =~ m/\A(?:From|To|Subject)\z/;
                next unless $e =~ m/\A\z/;
                $rfc822next->{ lc $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless 
                ( $e =~ $RxMTA->{'begin'} ) .. 
                ( grep { $e =~ $_ } @{ $RxMTA->{'rfc822'} } );
            next unless length $e;

            #    ----- Transcript of session follows -----
            # While talking to smtp.example.com:
            # >>> RCPT To:<kijitora@example.org>
            # <<< 550 <kijitora@example.org>, User Unknown
            # 550 <kijitora@example.org>... User unknown
            # 421 example.org (smtp)... Deferred: Connection timed out during user open with example.org
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A\d{3}\s+[<]([^ ]+[@][^ ]+)[>][.]{3}\s*(.+)\z/ ) {
                # 550 <kijitora@example.org>... User unknown
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'}  = $1;
                $v->{'diagnosis'}  = $2;

                if( $responding->[ $recipients ] ) {
                    # Concatenate the response of the server and error message
                    $v->{'diagnosis'} .= ': '.$responding->[ $recipients ];
                }
                $recipients++;

            } elsif( $e =~ m/\A[>]{3}\s*([A-Z]{4})\s*/ ) {
                # >>> RCPT To:<kijitora@example.org>
                $commandset->[ $recipients ] = $1;

            } elsif( $e =~ m/\A[<]{3}[ ]+(.+)\z/ ) {
                # <<< Response
                # <<< 501 <shironeko@example.co.jp>... no access from mail server [192.0.2.55] which is an open relay.
                # <<< 550 Requested User Mailbox not found. No such user here.
                $responding->[ $recipients ] = $1;

            } else {
                # Detect SMTP session error or connection error
                next if $v->{'sessionerr'};
                if( $e =~ $RxMTA->{'error'} ) { 
                    # ----- Transcript of session follows -----
                    # ... while talking to mta.example.org.:
                    $v->{'sessionerr'} = 1;
                    next;
                }

                if( $e =~ m/\A\d{3}\s+.+[.]{3}\s*(.+)\z/ ) {
                    # 421 example.org (smtp)... Deferred: Connection timed out during user open with example.org
                    $anotherset->{'diagnosis'} = $1;
                }
            }

        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }
    return undef unless $match;

    unless( $recipients ) {
        # Get the recipient address from the original message
        if( $rfc822part =~ m/^To: (.+)$/m ) {
            # The value of To: header in the original message
            $dscontents->[0]->{'recipient'} = Sisimai::Address->s3s4( $1 );
            $recipients = 1;
        }
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC5322;

    my $n = -1;
    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $n++;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'spec'}    ||= 'SMTP';
        $e->{'agent'}   ||= __PACKAGE__->smtpagent;
        $e->{'command'}   = $commandset->[ $n ] || '';

        if( exists $anotherset->{'diagnosis'} && length $anotherset->{'diagnosis'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $anotherset->{'diagnosis'};

        } else {
            # Set server response as a error message
            $e->{'diagnosis'} ||= $responding->[ $n ];
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        unless( $e->{'recipient'} =~ m/\A[^ ]+[@][^ ]+\z/ ) {
            # @example.jp, no local part
            if( $e->{'diagnosis'} =~ m/[<]([^ ]+[@][^ ]+)[>]/ ) {
                # Get email address from the value of Diagnostic-Code header
                $e->{'recipient'} = $1;
            }
        }
        delete $e->{'sessionerr'};
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::V5sendmail - bounce mail parser class for C<V5 Sendmail>.

=head1 SYNOPSIS

    use Sisimai::MTA::V5sendmail;

=head1 DESCRIPTION

Sisimai::MTA::V5sendmail parses a bounce email which created by C<Sendmail 
version 5>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::V5sendmail->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::V5sendmail->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::V5sendmail->smtpagent;

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
