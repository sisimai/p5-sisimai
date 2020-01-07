package Sisimai::Lhost::IMailServer;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $ReBackbone = qr|^Original[ ]message[ ]follows[.]|m;
my $StartingOf = { 'error' => ['Body of message generated response:'] };

my $ReSMTP = {
    'conn' => qr/(?:SMTP connection failed,|Unexpected connection response from server:)/,
    'ehlo' => qr|Unexpected response to EHLO/HELO:|,
    'mail' => qr|Server response to MAIL FROM:|,
    'rcpt' => qr|Additional RCPT TO generated following response:|,
    'data' => qr|DATA command generated response:|,
};
my $ReFailures = {
    'hostunknown' => qr/Unknown host/,
    'userunknown' => qr/\A(?:Unknown user|Invalid final delivery userid)/,
    'mailboxfull' => qr/\AUser mailbox exceeds allowed size/,
    'securityerr' => qr/\ARequested action not taken: virus detected/,
    'undefined'   => qr/\Aundeliverable to/,
    'expired'     => qr/\ADelivery failed \d+ attempts/,
};

# X-Mailer: <SMTP32 v8.22>
sub headerlist  { return ['x-mailer'] }
sub description { 'IPSWITCH IMail Server' }
sub make {
    # Detect an error from IMailServer
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
    # @since v4.1.1
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match ||= 1 if $mhead->{'subject'} =~ /\AUndeliverable Mail[ ]*\z/;
    $match ||= 1 if defined $mhead->{'x-mailer'} && index($mhead->{'x-mailer'}, '<SMTP32 v') == 0;
    return undef unless $match;

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailsteak = Sisimai::RFC5322->fillet($mbody, $ReBackbone);
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;

    for my $e ( split("\n", $emailsteak->[0]) ) {
        # Read error messages and delivery status lines from the head of the email
        # to the previous line of the beginning of the original message.

        # Unknown user: kijitora@example.com
        #
        # Original message follows.
        $v = $dscontents->[-1];

        if( $e =~ /\A([^ ]+)[ ](.+)[:][ \t]*([^ ]+[@][^ ]+)/ ) {
            # Unknown user: kijitora@example.com
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'diagnosis'} = $1.' '.$2;
            $v->{'recipient'} = $3;
            $recipients++;

        } elsif( $e =~ /\Aundeliverable[ ]+to[ ]+(.+)\z/ ) {
            # undeliverable to kijitora@example.com
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'recipient'} = $1;
            $recipients++;

        } else {
            # Other error message text
            $v->{'alterrors'} //= '';
            $v->{'alterrors'}  .= ' '.$e if $v->{'alterrors'};
            $v->{'alterrors'}   = $e if index($e, $StartingOf->{'error'}->[0]) > -1;
        }
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( exists $e->{'alterrors'} && $e->{'alterrors'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} = $e->{'alterrors'}.' '.$e->{'diagnosis'};
            $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
            delete $e->{'alterrors'};
        }
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        COMMAND: for my $r ( keys %$ReSMTP ) {
            # Detect SMTP command from the message
            next unless $e->{'diagnosis'} =~ $ReSMTP->{ $r };
            $e->{'command'} = uc $r;
            last;
        }

        SESSION: for my $r ( keys %$ReFailures ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $ReFailures->{ $r };
            $e->{'reason'} = $r;
            last;
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailsteak->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::IMailServer - bounce mail parser class for C<IMail Server>.

=head1 SYNOPSIS

    use Sisimai::Lhost::IMailServer;

=head1 DESCRIPTION

Sisimai::Lhost::IMailServer parses a bounce email which created by
C<Ipswitch IMail Server>. Methods in the module are called from only
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::IMailServer->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::IMailServer->smtpagent;

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

