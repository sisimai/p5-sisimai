package Sisimai::Lhost::EinsUndEins;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $RFC822Mark = qr|^--- The header of the original message is following[.] ---$|ms;
my $StartingOf = {
    'message' => ['This message was created automatically by mail delivery software'],
    'error'   => ['For the following reason:'],
};
my $MessagesOf = { 'mesgtoobig' => ['Mail size limit exceeded'] };

# X-UI-Out-Filterresults: unknown:0;
sub description { '1&1: https://www.1und1.de/' }
sub make {
    # Detect an error from 1&1
    # @param         [Hash] mhead       Message headers of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.1.9
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless index($mhead->{'from'}, '"Mail Delivery System"') == 0;
    return undef unless $mhead->{'subject'} eq 'Mail delivery failed: returning message to sender';

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;
    my ($dsmessages, $rfc822text) = split($RFC822Mark, $$mbody, 2);

    for my $e ( split("\n", $dsmessages) ) {
        # Read each line of message/delivery-status part and error messages
        next unless length $e;

        # The following address failed:
        #
        # general@example.eu
        #
        # For the following reason:
        #
        # Mail size limit exceeded. For explanation visit
        # http://postmaster.1and1.com/en/error-messages?ip=%1s
        $v = $dscontents->[-1];

        if( $e =~ /\A([^ ]+[@][^ ]+)\z/ ) {
            # general@example.eu
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'recipient'} = $1;
            $recipients++;

        } elsif( index($e, $StartingOf->{'error'}->[0]) == 0 ) {
            # For the following reason:
            $v->{'diagnosis'} = $e;

        } else {
            if( length $v->{'diagnosis'} ) {
                # Get error message and append the error message strings
                $v->{'diagnosis'} .= ' '.$e;

            } else {
                # OR the following format:
                #   neko@example.fr:
                #   SMTP error from remote server for TEXT command, host: ...
                $v->{'alterrors'} .= ' '.$e;
            }
        } # End of error message part
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'agent'}       =  __PACKAGE__->smtpagent;
        $e->{'diagnosis'} ||= $e->{'alterrors'} || '';

        if( $e->{'diagnosis'} =~ /host:[ ]+(.+?)[ ]+.+[ ]+reason:.+/ ) {
            # SMTP error from remote server for TEXT command,
            #   host: smtp-in.orange.fr (193.252.22.65)
            #   reason: 550 5.2.0 Mail rejete. Mail rejected. ofr_506 [506]
            $e->{'rhost'}   = $1;
            $e->{'command'} = 'DATA' if $e->{'diagnosis'} =~ /for TEXT command/;
            $e->{'spec'}    = 'SMTP' if $e->{'diagnosis'} =~ /SMTP error/;
            $e->{'status'}  = Sisimai::SMTP::Status->find($e->{'diagnosis'});
        } else {
            # For the following reason:
            $e->{'diagnosis'} =~ s/\A$StartingOf->{'error'}->[0]//g;
        }
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        SESSION: for my $r ( keys %$MessagesOf ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } @{ $MessagesOf->{ $r } };
            $e->{'reason'} = $r;
            last;
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822text };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::EinsUndEins - bounce mail parser class for C<1&1>.

=head1 SYNOPSIS

    use Sisimai::Lhost::EinsUndEins;

=head1 DESCRIPTION

Sisimai::Lhost::EinsUndEins parses a bounce email which created by C<1&1>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::EinsUndEins->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::EinsUndEins->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2020 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

