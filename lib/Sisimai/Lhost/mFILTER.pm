package Sisimai::Lhost::mFILTER;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $ReBackbone = qr/^-------original[ ](?:message|mail[ ]info)/m;
my $StartingOf = {
    'command'  => ['-------SMTP command'],
    'error'    => ['-------server message'],
};
my $MarkingsOf = { 'message' => qr/\A[^ ]+[@][^ ]+[.][a-zA-Z]+\z/ };

sub description { 'Digital Arts m-FILTER' }
sub make {
    # Detect an error from DigitalArts m-FILTER
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

    # X-Mailer: m-FILTER
    return undef unless defined $mhead->{'x-mailer'};
    return undef unless $mhead->{'x-mailer'} eq 'm-FILTER';
    return undef unless $mhead->{'subject'}  eq 'failure notice';

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailsteak = Sisimai::RFC5322->fillet($mbody, $ReBackbone);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $markingset = { 'diagnosis' => 0, 'command' => 0 };
    my $v = undef;

    for my $e ( split("\n", $emailsteak->[0]) ) {
        # Read error messages and delivery status lines from the head of the email
        # to the previous line of the beginning of the original message.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            $readcursor |= $Indicators->{'deliverystatus'} if $e =~ $MarkingsOf->{'message'};
        }
        next unless $readcursor & $Indicators->{'deliverystatus'};
        next unless length $e;

        # このメールは「m-FILTER」が自動的に生成して送信しています。
        # メールサーバーとの通信中、下記の理由により
        # このメールは送信できませんでした。
        #
        # 以下のメールアドレスへの送信に失敗しました。
        # kijitora@example.jp
        #
        #
        # -------server message
        # 550 5.1.1 unknown user <kijitora@example.jp>
        #
        # -------SMTP command
        # DATA
        #
        # -------original message
        $v = $dscontents->[-1];

        if( $e =~ /\A([^ ]+[@][^ ]+)\z/ ) {
            # 以下のメールアドレスへの送信に失敗しました。
            # kijitora@example.jp
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'recipient'} = $1;
            $recipients++;

        } elsif( $e =~ /\A[A-Z]{4}/ ) {
            # -------SMTP command
            # DATA
            next if $v->{'command'};
            $v->{'command'} = $e if $markingset->{'command'};

        } else {
            # Get error message and SMTP command
            if( $e eq $StartingOf->{'error'}->[0] ) {
                # -------server message
                $markingset->{'diagnosis'} = 1;

            } elsif( $e eq $StartingOf->{'command'}->[0] ) {
                # -------SMTP command
                $markingset->{'command'} = 1;

            } else {
                # 550 5.1.1 unknown user <kijitora@example.jp>
                next if index($e, '-') == 0;
                next if $v->{'diagnosis'};
                $v->{'diagnosis'} = $e;
            }
        } # End of error message part
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'agent'}     = __PACKAGE__->smtpagent;

        # Get localhost and remote host name from Received header.
        next unless scalar @{ $mhead->{'received'} };
        my $rheads = $mhead->{'received'};
        my $rhosts = Sisimai::RFC5322->received($rheads->[-1]);

        $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received($rheads->[0]) };
        for my $ee ( @$rhosts ) {
            # Avoid "... by m-FILTER"
            next unless rindex($ee, '.') > -1;
            $e->{'rhost'} = $ee;
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailsteak->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::mFILTER - bounce mail parser class for C<Digital Arts m-FILTER>.

=head1 SYNOPSIS

    use Sisimai::Lhost::mFILTER;

=head1 DESCRIPTION

Sisimai::Lhost::mFILTER parses a bounce email which created by
C<Digital Arts m-FILTER>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::mFILTER->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::mFILTER->smtpagent;

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

