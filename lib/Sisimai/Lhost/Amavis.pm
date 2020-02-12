package Sisimai::Lhost::Amavis;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

state $Indicators = __PACKAGE__->INDICATORS;
state $ReBackbone = qr|^Content-Type:[ ]text/rfc822-headers|m;
state $StartingOf = { 'message' => ['The message '] };

# https://www.amavis.org
sub description { 'amavisd-new: https://www.amavis.org/' }
sub make {
    # Detect an error from amavisd-new
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
    # @since v4.25.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    # From: "Content-filter at neko1.example.jp" <postmaster@neko1.example.jp>
    # Subject: Undeliverable mail, MTA-BLOCKED
    return undef unless index($mhead->{'from'}, '"Content-filter at ') == 0;

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailsteak = Sisimai::RFC5322->fillet($mbody, $ReBackbone);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;

    for my $e ( split("\n", $emailsteak->[0]) ) {
        # Read error messages and delivery status lines from the head of the email
        # to the previous line of the beginning of the original message.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            $readcursor |= $Indicators->{'deliverystatus'} if index($e, $StartingOf->{'message'}->[0]) == 0;
            next;
        }
        next unless $readcursor & $Indicators->{'deliverystatus'};
        next unless length $e;
        next unless my $f = Sisimai::RFC1894->match($e);

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
            $v->{'spec'} = 'SMTP' if $v->{'spec'} eq 'X-POSTFIX';
            $v->{'diagnosis'} = $o->[2];

        } else {
            # Other DSN fields defined in RFC3464
            next unless exists $fieldtable->{ $o->[0] };
            $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

            next unless $f == 1;
            $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
        }
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;

        $e->{'diagnosis'} ||= Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'agent'}       = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailsteak->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::Amavis - bounce mail parser class for C<amavisd-new>.

=head1 SYNOPSIS

    use Sisimai::Lhost::Amavis;

=head1 DESCRIPTION

Sisimai::Lhost::Amavis parses a bounce email which created by C<amavisd-new>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Amavis->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::Amavis->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2019,2020 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut


