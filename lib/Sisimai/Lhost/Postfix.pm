package Sisimai::Lhost::Postfix;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $StartingOf = { 'rfc822' => ['Content-Type: message/rfc822', 'Content-Type: text/rfc822-headers'] };
my $MarkingsOf = {
    # Postfix manual - bounce(5) - http://www.postfix.org/bounce.5.html
    'begin' => qr{\A(?>
         [ ]+The[ ](?:
             Postfix[ ](?:
                 program\z              # The Postfix program
                |on[ ].+[ ]program\z    # The Postfix on <os name> program
                )
            |\w+[ ]Postfix[ ]program\z  # The <name> Postfix program
            |mail[ \t]system\z             # The mail system
            |\w+[ \t]program\z             # The <custmized-name> program
            )
        |This[ ]is[ ]the[ ](?:
             Postfix[ ]program          # This is the Postfix program
            |\w+[ ]Postfix[ ]program    # This is the <name> Postfix program
            |\w+[ ]program              # This is the <customized-name> Postfix program
            |mail[ ]system[ ]at[ ]host  # This is the mail system at host <hostname>.
            )
        )
    }x,
};

sub description { 'Postfix' }
sub make {
    # Parse bounce messages from Postfix
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

    # 'from'    => qr/ [(]Mail Delivery System[)]\z/,
    return undef unless $mhead->{'subject'} eq 'Undelivered Mail Returned to Sender';

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $anotherset = {};    # (Hash) Another error information
    my @commandset;         # (Array) ``in reply to * command'' list
    my $v = undef;
    my $p = '';

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            if( $e =~ $MarkingsOf->{'begin'} ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part(message/rfc822)
            if( $e eq $StartingOf->{'rfc822'}->[0] || $e eq $StartingOf->{'rfc822'}->[0] ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # message/rfc822 OR text/rfc822-headers part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # message/delivery-status part
            next unless $readcursor & $Indicators->{'deliverystatus'};
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
                    $v->{'spec'} = 'SMTP' if $v->{'spec'} eq 'X-POSTFIX';
                    $v->{'diagnosis'} = $o->[2];

                } else {
                    # Other DSN fields defined in RFC3464
                    next unless exists $fieldtable->{ $o->[0] };
                    $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                    next unless $f == 1;
                    $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
                }
            } else {
                # If you do so, please include this problem report. You can
                # delete your own text from the attached returned message.
                #
                #           The mail system
                #
                # <userunknown@example.co.jp>: host mx.example.co.jp[192.0.2.153] said: 550
                # 5.1.1 <userunknown@example.co.jp>... User Unknown (in reply to RCPT TO
                # command)
                if( index($p, 'Diagnostic-Code:') == 0 && $e =~ /\A[ \t]+(.+)\z/ ) {
                    # Continued line of the value of Diagnostic-Code header
                    $v->{'diagnosis'} .= ' '.$1;
                    $e = 'Diagnostic-Code: '.$e;

                } elsif( $e =~ /\A(X-Postfix-Sender):[ ]*rfc822;[ ]*(.+)\z/ ) {
                    # X-Postfix-Sender: rfc822; shironeko@example.org
                    push @$rfc822list, $1.': '.$2;

                } else {
                    # Alternative error message and recipient

                    if( $e =~ /[ \t][(]in reply to ([A-Z]{4}).*/ ) {
                        # 5.1.1 <userunknown@example.co.jp>... User Unknown (in reply to RCPT TO
                        push @commandset, $1;
                        $anotherset->{'diagnosis'} .= ' '.$e if $anotherset->{'diagnosis'};

                    } elsif( $e =~ /([A-Z]{4})[ \t]*.*command[)]\z/ ) {
                        # to MAIL command)
                        push @commandset, $1;
                        $anotherset->{'diagnosis'} .= ' '.$e if $anotherset->{'diagnosis'};

                    } elsif( $e =~ /\A[<]([^ ]+[@][^ ]+)[>] [(]expanded from [<](.+)[>][)]:[ \t]*(.+)\z/ ) {
                        # <r@example.ne.jp> (expanded from <kijitora@example.org>): user ...
                        $anotherset->{'recipient'} = $1;
                        $anotherset->{'alias'}     = $2;
                        $anotherset->{'diagnosis'} = $3;

                    } elsif( $e =~ /\A[<]([^ ]+[@][^ ]+)[>]:(.*)\z/ ) {
                        # <kijitora@exmaple.jp>: ...
                        $anotherset->{'recipient'} = $1;
                        $anotherset->{'diagnosis'} = $2;

                    } else {
                        # Get error message continued from the previous line
                        next unless $anotherset->{'diagnosis'};
                        $anotherset->{'diagnosis'} .= ' '.$e if $e =~ /\A[ \t]{4}(.+)\z/;
                    }
                }
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }

    unless( $recipients ) {
        # Fallback: set recipient address from error message
        if( defined $anotherset->{'recipient'} && $anotherset->{'recipient'} ) {
            # Set recipient address
            $dscontents->[-1]->{'recipient'} = $anotherset->{'recipient'};
            $recipients++;
        }
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'lhost'} ||= $permessage->{'rhost'};
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;

        if( exists $anotherset->{'diagnosis'} && $anotherset->{'diagnosis'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $anotherset->{'diagnosis'};
            if( $e->{'diagnosis'} =~ /\A\d+\z/ ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $anotherset->{'diagnosis'};

            } else {
                # More detailed error message is in "$anotherset"
                my $as = undef; # status
                my $ar = undef; # replycode

                if( $e->{'status'} eq '' || substr($e->{'status'}, -4, 4) eq '.0.0' ) {
                    # Check the value of D.S.N. in $anotherset
                    $as = Sisimai::SMTP::Status->find($anotherset->{'diagnosis'}) || '';
                    if( length($as) > 0 && substr($as, -4, 4) ne '.0.0' ) {
                        # The D.S.N. is neither an empty nor *.0.0
                        $e->{'status'} = $as;
                    }
                }

                if( $e->{'replycode'} eq '' || substr($e->{'replycode'}, -2, 2) eq '00' ) {
                    # Check the value of SMTP reply code in $anotherset
                    $ar = Sisimai::SMTP::Reply->find($anotherset->{'diagnosis'}) || '';
                    if( length($ar) > 0 && substr($ar, -2, 2) ne '00' ) {
                        # The SMTP reply code is neither an empty nor *00
                        $e->{'replycode'} = $ar;
                    }
                }

                if( $as || $ar && ( length($anotherset->{'diagnosis'}) > length($e->{'diagnosis'}) ) ) {
                    # Update the error message in $e->{'diagnosis'}
                    $e->{'diagnosis'} = $anotherset->{'diagnosis'};
                }
            }
        }
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'command'}   = shift @commandset || '';
        $e->{'command'} ||= 'HELO' if $e->{'diagnosis'} =~ /refused to talk to me:/;
        $e->{'spec'}    ||= 'SMTP' if $e->{'diagnosis'} =~ /host .+ said:/;
        $e->{'agent'}     = __PACKAGE__->smtpagent;
    }
    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::Postfix - bounce mail parser class for C<Postfix>.

=head1 SYNOPSIS

    use Sisimai::Lhost::Postfix;

=head1 DESCRIPTION

Sisimai::Lhost::Postfix parses a bounce email which created by C<Postfix>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Postfix->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::Postfix->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

