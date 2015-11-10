package Sisimai::MSP::US::Zoho;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'from'     => qr/mailer-daemon[@]mail[.]zoho[.]com\z/,
    'subject'  => qr{\A(?:
                     Undelivered[ ]Mail[ ]Returned[ ]to[ ]Sender
                    |Mail[ ]Delivery[ ]Status[ ]Notification
                    )
                  }x,
    'x-mailer' => qr/\AZoho Mail\z/,
};
my $Re1 = {
    'begin'  => qr/\AThis message was created automatically by mail delivery/,
    'rfc822' => qr/\AReceived:\s*from mail[.]zoho[.]com/,
    'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $ReFailure = {
    'expired' => qr/Host not reachable/
};

sub description { 'Zoho Mail: https://www.zoho.com' }
sub smtpagent   { 'US::Zoho' }
sub headerlist  { 
    return [ 'X-Mailer', 'X-ZohoMail' ],
}

sub scan {
    # Detect an error from Zoho Mail
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
    # @since v4.1.7
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'from'}     =~ $Re0->{'from'};
    return undef unless $mhead->{'subject'}  =~ $Re0->{'subject'};
    return undef unless $mhead->{'x-mailer'} =~ $Re0->{'x-mailer'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name
    my $qprintable = 0;

    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $indicators = __PACKAGE__->INDICATORS;

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        $e =~ s{=\d+\z}{};

        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $Re1->{'begin'} ) {
                $readcursor |= $indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $Re1->{'rfc822'} ) {
                $readcursor |= $indicators->{'message-rfc822'};
                next;
            }
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

            # This message was created automatically by mail delivery software.
            # A message that you sent could not be delivered to one or more of its recip=
            # ients. This is a permanent error.=20
            #
            # kijitora@example.co.jp Invalid Address, ERROR_CODE :550, ERROR_CODE :5.1.=
            # 1 <kijitora@example.co.jp>... User Unknown

            # This message was created automatically by mail delivery software.
            # A message that you sent could not be delivered to one or more of its recipients. This is a permanent error. 
            #
            # shironeko@example.org Invalid Address, ERROR_CODE :550, ERROR_CODE :Requested action not taken: mailbox unavailable
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A([^ ]+[@][^ ]+)\s+(.+)\z/ ) {
                # kijitora@example.co.jp Invalid Address, ERROR_CODE :550, ERROR_CODE :5.1.=
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

                $v->{'diagnosis'} =  $2;
                if( $v->{'diagnosis'} =~ m/=\z/ ) {
                    # Quoted printable
                    $v->{'diagnosis'} =~ s/=\z//;
                    $qprintable = 1;
                }

            } elsif( $e =~ m/\A\[Status: .+[<]([^ ]+[@][^ ]+)[>],/ ) {
                # Expired
                # [Status: Error, Address: <kijitora@6kaku.example.co.jp>, ResponseCode 421, , Host not reachable.]
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

                $v->{'diagnosis'} = $e;

            } else {
                # Continued line
                next unless $qprintable;
                $v->{'diagnosis'} .= $e;
            }
        } # End of if: rfc822

    } continue {
        # Save the current line for the next loop
        $p = $e;
        $e = '';
    }

    return undef unless $recipients;
    require Sisimai::String;
    require Sisimai::RFC3463;
    require Sisimai::RFC5322;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }

        $e->{'diagnosis'} =~ s{\\n}{ }g;
        $e->{'diagnosis'} =  Sisimai::String->sweep( $e->{'diagnosis'} );

        SESSION: for my $r ( keys %$ReFailure ) {
            # Verify each regular expression of session errors
            next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
            $e->{'reason'} = $r;
            last;
        }

        $e->{'status'} =  Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'} ||= 'SMTP';
        $e->{'agent'}  = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MSP::US::Zoho - bounce mail parser class for C<Zoho! MAIL>.

=head1 SYNOPSIS

    use Sisimai::MSP::US::Zoho;

=head1 DESCRIPTION

Sisimai::MSP::US::Zoho parses a bounce email which created by C<Zoho! MAIL>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::US::Zoho->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::US::Zoho->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

