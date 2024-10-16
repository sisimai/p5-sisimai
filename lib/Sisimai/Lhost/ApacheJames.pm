package Sisimai::Lhost::ApacheJames;
use parent 'Sisimai::Lhost';
use v5.26;
use strict;
use warnings;

sub description { 'James: https://james.apache.org/' }
sub inquire {
    # Detect an error from Apache James
    # @param    [Hash] mhead    Message headers of a bounce email
    # @param    [String] mbody  Message body of a bounce email
    # @return   [Hash]          Bounce data list and message/rfc822 part
    # @return   [undef]         failed to decode or the arguments are missing
    # @since v4.1.26
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # 'subject'    => qr/\A\[BOUNCE\]\z/,
    # 'received'   => qr/JAMES SMTP Server/,
    # 'message-id' => qr/\d+[.]JavaMail[.].+[@]/,
    $match ||= 1 if $mhead->{'subject'} eq '[BOUNCE]';
    $match ||= 1 if defined $mhead->{'message-id'} && rindex($mhead->{'message-id'}, '.JavaMail.') > -1;
    $match ||= 1 if grep { rindex($_, 'JAMES SMTP Server') > -1 } $mhead->{'received'}->@*;
    return undef unless $match;

    state $indicators = __PACKAGE__->INDICATORS;
    state $boundaries = ['Content-Type: message/rfc822'];
    state $startingof = {
        # apache-james-2.3.2/src/java/org/apache/james/transport/mailets/
        #   AbstractNotify.java|124:  out.println("Error message below:");
        #   AbstractNotify.java|128:  out.println("Message details:");
        'message' => [''],
        'error'   => ['Error message below:'],
    };

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailparts = Sisimai::RFC5322->part($mbody, $boundaries);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $issuedcode = '';    # (String) Alternative diagnostic message
    my $subjecttxt = undef; # (String) Alternative Subject text
    my $gotmessage = 0;     # (Integer) Flag for error message
    my $v = undef;

    for my $e ( split("\n", $emailparts->[0]) ) {
        # Read error messages and delivery status lines from the head of the email to the previous
        # line of the beginning of the original message.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            $readcursor |= $indicators->{'deliverystatus'} if index($e, $startingof->{'message'}->[0]) == 0;
            next;
        }
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
        $v = $dscontents->[-1];

        if( index($e, '  RCPT TO: ') == 0 ) {
            #   RCPT TO: kijitora@example.org
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'recipient'} = substr($e, 12,);
            $recipients++;

        } elsif( index($e, '  Sent date: ') == 0 ) {
            #   Sent date: Thu Apr 29 01:20:50 JST 2015
            $v->{'date'} = substr($e, 13,);

        } elsif( index($e, '  Subject: ') == 0 ) {
            #   Subject: Nyaaan
            $subjecttxt = substr($e, 11,)

        } else {
            next if $gotmessage == 1;

            if( $v->{'diagnosis'} ) {
                # Get an error message text
                if( $e eq 'Message details:' ) {
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
                $v->{'diagnosis'} = $e if $e eq $startingof->{'error'}->[0];
                $v->{'diagnosis'} .= ' '.$e unless $gotmessage;
            }
        }
    }
    return undef unless $recipients;

    # Set the value of $subjecttxt as a Subject if there is no original message
    # in the bounce mail.
    $emailparts->[1] .= sprintf("Subject: %s\n", $subjecttxt) if index($emailparts->[1], "\nSubject:") < 0;
    $_->{'diagnosis'} = Sisimai::String->sweep($_->{'diagnosis'} || $issuedcode) for @$dscontents;
    return { 'ds' => $dscontents, 'rfc822' => $emailparts->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::ApacheJames - bounce mail decoder class for Apache James L<https://james.apache.org/>.

=head1 SYNOPSIS

    use Sisimai::Lhost::ApacheJames;

=head1 DESCRIPTION

C<Sisimai::Lhost::ApacheJames> decodes a bounce email which created by Apache James L<https://james.apache.org>.
Methods in the module are called from only C<Sisimai::Message>.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::ApacheJames->description;

=head2 C<B<inquire(I<header data>, I<reference to body string>)>>

C<inquire()> method decodes a bounced email and return results as a array reference.
See C<Sisimai::Message> for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015-2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

