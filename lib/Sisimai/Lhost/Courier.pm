package Sisimai::Lhost::Courier;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $RFC822Mark = qr{^Content-Type:\s*(?:message|text)/rfc822(?:-headers)?[^\r\n]*}ms;
my $MessagesOf = {
    # courier/module.esmtp/esmtpclient.c:526| hard_error(del, ctf, "No such domain.");
    'hostunknown' => ['No such domain.'],
    # courier/module.esmtp/esmtpclient.c:531| hard_error(del, ctf,
    # courier/module.esmtp/esmtpclient.c:532|  "This domain's DNS violates RFC 1035.");
    'systemerror' => ["This domain's DNS violates RFC 1035."],
    # courier/module.esmtp/esmtpclient.c:535| soft_error(del, ctf, "DNS lookup failed.");
    'networkerror'=> ['DNS lookup failed.'],
};

sub description { 'Courier MTA' }
sub make {
    # Detect an error from Courier MTA
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
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match ||= 1 if index($mhead->{'from'}, 'Courier mail server at ') > -1;
    $match ||= 1 if $mhead->{'subject'} =~ /(?:NOTICE: mail delivery status[.]|WARNING: delayed mail[.])/;
    if( defined $mhead->{'message-id'} ) {
        # Message-ID: <courier.4D025E3A.00001792@5jo.example.org>
        $match ||= 1 if $mhead->{'message-id'} =~ /\A[<]courier[.][0-9A-F]+[.]/;
    }
    return undef unless $match;

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $anotherset = {};    # (Hash) Another error information
    my $v = undef;
    my $p = '';

    # https://www.courier-mta.org/courierdsn.html
    # courier/module.dsn/dsn*.txt
    my ($dsmessages, $rfc822text) = split($RFC822Mark, $$mbody, 2);
    $dsmessages =~ s/\A.+(?:DELAYS IN DELIVERING YOUR MESSAGE|UNDELIVERABLE MAIL)//ms;

    for my $e ( split("\n", $dsmessages) ) {
        # Read each line of message/delivery-status part and error messages
        next unless length $e;

        if( my $f = Sisimai::RFC1894->match($e) ) {
            # $e matched with any field defined in RFC3464
            next unless my $o = Sisimai::RFC1894->field($e);
            $v = $dscontents->[-1];

            if( $o->[-1] eq 'addr' ) {
                # Final-Recipient: rfc822; kijitora@example.jp
                # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                if( $o->[0] eq 'final-recipient' ) {
                    # Final-Recipient: rfc822; kijitora@example.jp
                    if( $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[-1];
                    }
                    $v->{'recipient'} = $o->[2];
                    $recipients++;

                } else {
                    # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                    $v->{'alias'} = $o->[2];
                }
            } elsif( $o->[-1] eq 'code' ) {
                # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                $v->{'spec'} = $o->[1];
                $v->{'diagnosis'} = $o->[2];

            } else {
                # Other DSN fields defined in RFC3464
                next unless exists $fieldtable->{ $o->[0] };
                $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                next unless $f == 1;
                $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
            }
        } else {
            # The line does not begin with a DSN field defined in RFC3464
            #
            # This is a delivery status notification from marutamachi.example.org,
            # running the Courier mail server, version 0.65.2.
            #
            # The original message was received on Sat, 11 Dec 2010 12:19:57 +0900
            # from [127.0.0.1] (c10920.example.com [192.0.2.20])
            #
            # ---------------------------------------------------------------------------
            #
            #                           UNDELIVERABLE MAIL
            #
            # Your message to the following recipients cannot be delivered:
            #
            # <kijitora@example.co.jp>:
            #    mx.example.co.jp [74.207.247.95]:
            # >>> RCPT TO:<kijitora@example.co.jp>
            # <<< 550 5.1.1 <kijitora@example.co.jp>... User Unknown
            #
            # ---------------------------------------------------------------------------
            if( $e =~ /\A[>]{3}[ ]+([A-Z]{4})[ ]?/ ) {
                # >>> DATA
                $commandtxt ||= $1;

            } elsif( index($e, '<<< ') == 0 ) {
                # <<< 450 4.1.7 <sironeko@exaple.jp>: Sender address rejected: ...
                $e =~ s/\A<<<\s*//;
                $anotherset->{'diagnosis'} = $e;
                $anotherset->{'recipient'} = Sisimai::Address->find($e, 1);
                $anotherset->{'status'} = Sisimai::SMTP::Status->find($e);
                $anotherset->{'code'} = Sisimai::SMTP::Reply->find($e);

            } else {
                # Continued line of the value of Diagnostic-Code field
                next unless index($p, 'Diagnostic-Code:') == 0;
                next unless $e =~ /\A[ \t]+(.+)\z/;
                $v->{'diagnosis'} .= ' '.$1;
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }

    unless( $recipients ) {
        # Fallback: Get the address from $anotherset->{'recipient'}
        $dscontents->[0]->{'recipient'} = $anotherset->{'recipient'}->[0]->{'address'} || '';
        $recipients += 1 if $dscontents->[0]->{'recipient'};
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'status'}    ||= $anotherset->{'status'}    || '';
        $e->{'code'}      ||= $anotherset->{'code'}      || '';
        $e->{'diagnosis'} ||= $anotherset->{'diagnosis'} || '';
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        for my $r ( keys %$MessagesOf ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } @{ $MessagesOf->{ $r } };
            $e->{'reason'} = $r;
            last;
        }
        $e->{'agent'}     = __PACKAGE__->smtpagent;
        $e->{'command'} ||= $commandtxt || '';
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822text };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::Courier - bounce mail parser class for C<Courier MTA>.

=head1 SYNOPSIS

    use Sisimai::Lhost::Courier;

=head1 DESCRIPTION

Sisimai::Lhost::Courier parses a bounce email which created by C<Courier MTA>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Courier->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::Courier->smtpagent;

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
