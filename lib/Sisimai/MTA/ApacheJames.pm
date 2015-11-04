package Sisimai::MTA::ApacheJames;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    # apache-james-2.3.2/src/java/org/apache/james/transport/mailets/
    #   AbstractNotify.java|124:  out.println("Error message below:");
    #   AbstractNotify.java|128:  out.println("Message details:");
    'begin'      => qr/\AContent-Disposition:[ ]inline/,
    'error'      => qr/\AError message below:\z/,
    'rfc822'     => qr|\AContent-Type: message/rfc822|,
    'endof'      => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'    => qr/\A\[BOUNCE\]\z/,
    'received'   => qr/JAMES SMTP Server/,
    'message-id' => qr/\d+[.]JavaMail[.].+[@]/,
};

sub description { 'Java Apache Mail Enterprise Server' }
sub smtpagent   { 'ApacheJames' }

sub scan {
    # Detect an error from ApacheJames
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
    # @since v4.1.26
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match = 1 if $mhead->{'subject'} =~ $RxMTA->{'subject'};
    $match = 1 if( defined $mhead->{'message-id'} && $mhead->{'message-id'} =~ $RxMTA->{'message-id'} );
    $match = 1 if grep { $_ =~ $RxMTA->{'received'} } @{ $mhead->{'received'} };
    return undef unless $match;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $indicators = __PACKAGE__->INDICATORS;

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $diagnostic = '';    # (String) Alternative diagnostic message
    my $subjecttxt = undef; # (String) Alternative Subject text
    my $gotmessage = -1;    # (Integer) Flag for error message

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor = $indicators->{'deliverystatus'} if $e =~ $RxMTA->{'begin'};
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor = $indicators->{'message-rfc822'} if $e =~ $RxMTA->{'rfc822'};
        }

        if( $readcursor & $indicators->{'message-rfc822'} ) {
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
            next unless $readcursor & $indicators->{'deliverystatus'};
            next unless length $e;

            # Message details:
            #   Subject: Nyaaan
            #   Sent date: Thu Apr 29 01:20:50 JST 2015
            #   MAIL FROM: shironeko@example.jp
            #   RCPT TO: kijitora@example.org
            #   From: Neko <shironeko@example.jp> 
            #   To: kijitora@example.org
            #   Size (in bytes): 1024
            #   Number of lines: 64
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A[ ][ ]RCPT[ ]TO:[ ]([^ ]+[@][^ ]+)\z/ ) {
                #   RCPT TO: kijitora@example.org
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( $e =~ m/\A[ ][ ]Sent[ ]date:[ ](.+)\z/ ) {
                #   Sent date: Thu Apr 29 01:20:50 JST 2015
                $v->{'date'} = $1;

            } elsif( $e =~ m/\A[ ][ ]Subject:[ ](.+)\z/ ) {
                #   Subject: Nyaaan
                $subjecttxt = $1;

            } else {
                next if $gotmessage == 1;

                if( $v->{'diagnosis'} ) {
                    # Get an error message text
                    if( $e =~ m/\AMessage[ ]details:\z/ ) {
                        # Message details:
                        #   Subject: nyaan
                        #   ...
                        $gotmessage = 1;

                    } else {
                        # Append error message text like the followng:
                        #   Error message below:
                        #   550 - Requested action not taken: no such user here
                        $v->{'diagnosis'} .= ' '.$e;
                    }

                } else {
                    # Error message below:
                    # 550 - Requested action not taken: no such user here
                    $v->{'diagnosis'} = $e if $e =~ $RxMTA->{'error'};
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

    unless( $rfc822part =~ m/\bSubject:/ ) {
        # Set the value of $subjecttxt as a Subject if there is no original
        # message in the bounce mail.
        $rfc822part .= sprintf( "Subject: %s\n", $subjecttxt );
    }

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} || $diagnostic );
        $e->{'status'}    = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::ApacheJames - bounce mail parser class for C<ApacheJames>.

=head1 SYNOPSIS

    use Sisimai::MTA::ApacheJames;

=head1 DESCRIPTION

Sisimai::MTA::ApacheJames parses a bounce email which created by C<ApacheJames>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::ApacheJames->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::ApacheJames->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

