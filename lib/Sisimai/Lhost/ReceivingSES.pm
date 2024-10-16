package Sisimai::Lhost::ReceivingSES;
use parent 'Sisimai::Lhost';
use v5.26;
use strict;
use warnings;

sub description { 'Amazon SES(Receiving): https://aws.amazon.com/ses/' };
sub inquire {
    # Detect an error from Amazon SES/Receiving
    # @param    [Hash] mhead    Message headers of a bounce email
    # @param    [String] mbody  Message body of a bounce email
    # @return   [Hash]          Bounce data list and message/rfc822 part
    # @return   [undef]         failed to decode or the arguments are missing
    # @see      https://aws.amazon.com/ses/
    # @since v4.1.29
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    # X-SES-Outgoing: 2015.10.01-54.240.27.7
    # Feedback-ID: 1.us-west-2.HX6/J9OVlHTadQhEu1+wdF9DBj6n6Pa9sW5Y/0pSOi8=:AmazonSES
    return undef unless $mhead->{'x-ses-outgoing'};

    state $indicators = __PACKAGE__->INDICATORS;
    state $boundaries = ['Content-Type: text/rfc822-headers'];
    state $startingof = { 'message' => ['This message could not be delivered.'] };
    state $messagesof = {
        # The followings are error messages in Rule sets/*/Actions/Template
        'filtered'     => ['Mailbox does not exist'],
        'mesgtoobig'   => ['Message too large'],
        'mailboxfull'  => ['Mailbox full'],
        'contenterror' => ['Message content rejected'],
    };

    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field
    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailparts = Sisimai::RFC5322->part($mbody, $boundaries);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;
    my $p = '';

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
            # Continued line of the value of Diagnostic-Code field
            next unless index($p, 'Diagnostic-Code:') == 0;
            next unless index($e, ' ') == 0;
            $v->{'diagnosis'} .= ' '.Sisimai::String->sweep($e);
        }
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{ $_ } ||= $permessage->{ $_ } || '' for keys %$permessage;
        $e->{'diagnosis'} =~ y/\n/ /;
        $e->{'diagnosis'} =  Sisimai::String->sweep($e->{'diagnosis'});

        if( index($e->{'status'}, '.0.0') > 0 || index($e->{'status'}, '.1.0') > 0 ) {
            # Get other D.S.N. value from the error message
            # 5.1.0 - Unknown address error 550-'5.7.1 ...
            my $errormessage = $e->{'diagnosis'};
            my $p1 =  index($e->{'diagnosis'}, "-'"); $p1 =  index($e->{'diagnosis'}, '-"') if $p1 < 0;
            my $p2 = rindex($e->{'diagnosis'}, "' "); $p2 = rindex($e->{'diagnosis'}, '" ') if $p2 < 0;
            $errormessage  = substr($e->{'diagnosis'}, $p1 + 2, $p2 - $p1 - 2) if $p1 > -1 && $p2 > -1;
            $e->{'status'} = Sisimai::SMTP::Status->find($errormessage) || $e->{'status'};
        }

        SESSION: for my $r ( keys %$messagesof ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } $messagesof->{ $r }->@*;
            $e->{'reason'} = $r;
            last;
        }
        $e->{'reason'} ||= Sisimai::SMTP::Status->name($e->{'status'}) || '';
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailparts->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::ReceivingSES - bounce mail decoder class for Amazon SES C<https://aws.amazon.com/ses/>.

=head1 SYNOPSIS

    use Sisimai::Lhost::ReceivingSES;

=head1 DESCRIPTION

C<Sisimai::Lhost::ReceivingSES> decodes a bounce email which created by Amazon Simple Email Service
L<https://aws.amazon.com/ses/>. Methods in the module are called from only C<Sisimai::Message>.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::ReceivingSES->description;

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

