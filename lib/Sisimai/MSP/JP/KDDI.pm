package Sisimai::MSP::JP::KDDI;
use parent 'Sisimai::MSP';
use feature ':5.10';
use strict;
use warnings;

my $Re0 = {
    'from'       => qr/no-reply[@].+[.]dion[.]ne[.]jp/,
    'reply-to'   => qr/\Afrom\s+\w+[.]auone[-]net[.]jp\s/,
    'received'   => qr/\Afrom[ ](?:.+[.])?ezweb[.]ne[.]jp[ ]/,
    'message-id' => qr/[@].+[.]ezweb[.]ne[.]jp[>]\z/,
};
my $Re1 = {
    'begin' => qr/\AYour[ ]mail[ ](?:
                     sent[ ]on:?[ ][A-Z][a-z]{2}[,]
                    |attempted[ ]to[ ]be[ ]delivered[ ]on:?[ ][A-Z][a-z]{2}[,]
                    )
               /x,
    'rfc822' => qr|\AContent-Type: message/rfc822\z|,
    'error'  => qr/Could not be delivered to:? /,
    'endof'  => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $ReFailure = {
    'mailboxfull' => qr{
        As[ ]their[ ]mailbox[ ]is[ ]full
    }x,
    'norelaying' => qr{
        Due[ ]to[ ]the[ ]following[ ]SMTP[ ]relay[ ]error
    }x,
    'hostunknown' => qr{
        As[ ]the[ ]remote[ ]domain[ ]doesnt[ ]exist
    }x,
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'au by KDDI: http://www.au.kddi.com' }
sub smtpagent   { 'JP::KDDI' }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from KDDI
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
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    $match ||= 1 if $mhead->{'from'} =~ $Re0->{'from'};
    $match ||= 1 if $mhead->{'reply-to'} && $mhead->{'reply-to'} =~ $Re0->{'reply-to'};
    $match ||= 1 if grep { $_ =~ $Re0->{'received'} } @{ $mhead->{'received'} };
    return undef unless $match;

    require Sisimai::String;
    require Sisimai::Address;

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;

    for my $e ( @hasdivided ) {
        # Read each line between $Re1->{'begin'} and $Re1->{'rfc822'}.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $Re1->{'begin'} ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $Re1->{'rfc822'} ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
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

            } elsif( $e =~ m/\A\s+/ ) {
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
            next unless length $e;

            $v = $dscontents->[ -1 ];
            if( $e =~ m/\A\s+Could not be delivered to: [<]([^ ]+[@][^ ]+)[>]/ ) {
                # Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
                #     Could not be delivered to: <******@**.***.**>
                #     As their mailbox is full.
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }

                my $r = Sisimai::Address->s3s4( $1 );
                if( Sisimai::RFC5322->is_emailaddress( $r ) ) {
                    $v->{'recipient'} = $r;
                    $recipients++;
                }

            } elsif( $e =~ m/Your mail sent on: (.+)\z/ ) {
                # Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
                $v->{'date'} = $1;

            } else {
                #     As their mailbox is full.
                $v->{'diagnosis'} .= $e.' ' if $e =~ m/\A\s+/;
            }
        } # End of if: rfc822
    }

    return undef unless $recipients;
    require Sisimai::SMTP::Status;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );

        if( defined $mhead->{'x-spasign'} && $mhead->{'x-spasign'} eq 'NG' ) {
            # Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
            # Filtered recipient returns message that include 'X-SPASIGN' header
            $e->{'reason'} = 'filtered';

        } else {
            if( $e->{'command'} eq 'RCPT' ) {
                # set "userunknown" when the remote server rejected after RCPT
                # command.
                $e->{'reason'} = 'userunknown';

            } else {
                # SMTP command is not RCPT
                SESSION: for my $r ( keys %$ReFailure ) {
                    # Verify each regular expression of session errors
                    next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
                    $e->{'reason'} = $r;
                    last;
                }
            }
        }

        $e->{'status'} = Sisimai::SMTP::Status->find( $e->{'diagnosis'} );
        $e->{'spec'}   = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;

    } # end of for()

    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::MSP::JP::KDDI - bounce mail parser class for C<au by KDDI>.

=head1 SYNOPSIS

    use Sisimai::MSP::JP::KDDI;

=head1 DESCRIPTION

Sisimai::MSP::JP::KDDI parses a bounce email which created by C<au by KDDI>.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MSP::JP::KDDI->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MSP::JP::KDDI->smtpagent;

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
