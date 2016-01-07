package Sisimai::MTA::MailMarshalSMTP;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'subject'  => qr/\AUndeliverable Mail: ["]/,
};
my $Re1 = {
    'begin'    => qr/\AYour message:\z/,
    'rfc822'   => undef,
    'error'    => qr/\ACould not be delivered because of\z/,
    'rcpts'    => qr/\AThe following recipients were affected:/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'Trustwave Secure Email Gateway' }
sub smtpagent   { 'MailMarshalSMTP' }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from MailMarshalSMTP
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
    # @since v4.1.9
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $Re0->{'subject'};
    require Sisimai::MIME;

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $boundary00 = '';    # (String) Boundary string
    my $endoferror = 0;     # (Integer) Flag for the end of error message
    my $v = undef;

    $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
    $Re1->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;
    $Re1->{'rfc822'} = qr/\A[ \t]*[+]+[ \t]*\z/ unless $Re1->{'rfc822'};

    for my $e ( @hasdivided ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            $readcursor |= $Indicators->{'deliverystatus'} if $e =~ $Re1->{'begin'};
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            $readcursor |= $Indicators->{'message-rfc822'} if $e =~ $Re1->{'rfc822'};
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/ ) {
                # Get required headers only
                my $lhs = lc $1;

                $previousfn = '';
                next unless exists $RFC822Head->{ $lhs };

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[ \t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ $previousfn };
                $rfc822part .= $e."\n" if exists $LongFields->{ $previousfn };

            } else {
                # Check the end of headers in rfc822 part
                next unless exists $LongFields->{ $previousfn };
                next if length $e;
                $rfc822next->{ $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            next unless $readcursor & $Indicators->{'deliverystatus'};
            last if $e =~ $Re1->{'rfc822'};

            # Your message:
            #    From:    originalsender@example.com
            #    Subject: IIdentifica蟾ｽ驕俳
            #
            # Could not be delivered because of
            #
            # 550 5.1.1 User unknown
            #
            # The following recipients were affected: 
            #    dummyuser@blabla.xxxxxxxxxxxx.com
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A[ \t]{4}([^ ]+[@][^ ]+)\z/ ) {
                # The following recipients were affected: 
                #    dummyuser@blabla.xxxxxxxxxxxx.com
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } else {
                # Get error message lines
                if( $e =~ $Re1->{'error'} ) {
                    # Could not be delivered because of
                    #
                    # 550 5.1.1 User unknown
                    $v->{'diagnosis'} = $e;

                } elsif( length $v->{'diagnosis'} && $endoferror == 0 ) {
                    # Append error messages
                    $endoferror = 1 if $e =~ $Re1->{'rcpts'};
                    next if $endoferror;

                    $v->{'diagnosis'} .= ' '.$e;

                } else {
                    # Additional Information
                    # ======================
                    # Original Sender:    <originalsender@example.com>
                    # Sender-MTA:         <10.11.12.13>
                    # Remote-MTA:         <10.0.0.1>
                    # Reporting-MTA:      <relay.xxxxxxxxxxxx.com>
                    # MessageName:        <B549996730000.000000000001.0003.mml>
                    # Last-Attempt-Date:  <16:21:07 seg, 22 Dezembro 2014>
                    if( $e =~ m/\AOriginal Sender:[ \t]+[<](.+)[>]\z/ ) {
                        # Original Sender:    <originalsender@example.com>
                        # Use this line instead of "From" header of the original
                        # message.
                        $rfc822part .= sprintf("From: %s\n", $1 );

                    } elsif( $e =~ m/\ASender-MTA:[ \t]+[<](.+)[>]\z/ ) {
                        # Sender-MTA:         <10.11.12.13>
                        $v->{'lhost'} = $1;

                    } elsif( $e =~ m/\AReporting-MTA:[ \t]+[<](.+)[>]\z/ ) {
                        # Reporting-MTA:      <relay.xxxxxxxxxxxx.com>
                        $v->{'rhost'} = $1;
                    }
                }
            }
        } # End of if: rfc822
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::SMTP::Status;

    for my $e ( @$dscontents ) {
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r0 = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r0->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r0->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );
        $e->{'status'}    = Sisimai::SMTP::Status->find( $e->{'diagnosis'} );
        $e->{'spec'}      = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'}    = 'failed' if $e->{'status'} =~ m/\A[45]/;
    }

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::MailMarshalSMTP - bounce mail parser class for C<Trustwave> Secure
Email Gateway.

=head1 SYNOPSIS

    use Sisimai::MTA::MailMarshalSMTP;

=head1 DESCRIPTION

Sisimai::MTA::MailMarshalSMTP parses a bounce email which created by 
C<Trustwave> Secure Email Gateway: formerly MailMarshal SMTP. Methods in the
module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::MailMarshalSMTP->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::MailMarshalSMTP->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2016 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut


