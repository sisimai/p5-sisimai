package Sisimai::MTA::MailMarshalSMTP;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'begin'    => qr/\AYour message:\z/,
    'rfc822'   => undef,
    'error'    => qr/\ACould not be delivered because of\z/,
    'rcpts'    => qr/\AThe following recipients were affected:/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject'  => qr/\AUndeliverable Mail: ["]/,
};

sub version     { '4.0.0' }
sub description { 'Trustwave Secure Email Gateway' }
sub smtpagent   { 'MailMarshalSMTP' }
sub headerlist  { return [ 'X-Mailer' ] }

sub scan {
    # @Description  Detect an error from MailMarshalSMTP
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $RxMTA->{'subject'};
    require Sisimai::MIME;

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $boundary00 = '';    # (String) Boundary string
    my $endoferror = 0;     # (Integer) Flag for the end of error message

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    $boundary00 = Sisimai::MIME->boundary( $mhead->{'content-type'} );
    $RxMTA->{'rfc822'} = qr/\A[-]{2}$boundary00[-]{2}\z/ if length $boundary00;

    for my $e ( @$stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
            # After "message/rfc822"
            if( $e =~ m/\A([-0-9A-Za-z]+?)[:][ ]*(.+)\z/ ) {
                # Get required headers only
                my $lhs = $1;
                my $rhs = $2;

                $previousfn = '';
                next unless grep { lc( $lhs ) eq lc( $_ ) } @$rfc822head;

                $previousfn  = $lhs;
                $rfc822part .= $e."\n";

            } elsif( $e =~ m/\A[\s\t]+/ ) {
                # Continued line from the previous line
                next if $rfc822next->{ lc $previousfn };
                $rfc822part .= $e."\n" if $previousfn =~ m/\A(?:From|To|Subject)\z/;

            } else {
                # Check the end of headers in rfc822 part
                next unless $previousfn =~ m/\A(?:From|To|Subject)\z/;
                next unless $e =~ m/\A\z/;
                $rfc822next->{ lc $previousfn } = 1;
            }

        } else {
            # Before "message/rfc822"
            last if $e =~ $RxMTA->{'rfc822'};

            # Your message:
            #    From:    originalsender@example.com
            #    Subject: IIdentificação
            #
            # Could not be delivered because of
            #
            # 550 5.1.1 User unknown
            #
            # The following recipients were affected: 
            #    dummyuser@blabla.xxxxxxxxxxxx.com
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A\s{4}([^ ]+[@][^ ]+)\z/ ) {
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
                if( $e =~ $RxMTA->{'error'} ) {
                    # Could not be delivered because of
                    #
                    # 550 5.1.1 User unknown
                    $v->{'diagnosis'} = $e;

                } elsif( length $v->{'diagnosis'} && $endoferror == 0 ) {
                    # Append error messages
                    $endoferror = 1 if $e =~ $RxMTA->{'rcpts'};
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
                    if( $e =~ m/\AOriginal Sender:\s+[<](.+)[>]\z/ ) {
                        # Original Sender:    <originalsender@example.com>
                        # Use this line instead of "From" header of the original
                        # message.
                        $rfc822part .= sprintf("From: %s\n", $1 );

                    } elsif( $e =~ m/\ASender-MTA:\s+[<](.+)[>]\z/ ) {
                        # Sender-MTA:         <10.11.12.13>
                        $v->{'lhost'} = $1;

                    } elsif( $e =~ m/\AReporting-MTA:\s+[<](.+)[>]\z/ ) {
                        # Reporting-MTA:      <relay.xxxxxxxxxxxx.com>
                        $v->{'rhost'} = $1;
                    }
                }
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
        $e->{'agent'} ||= __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            $e->{'rhost'} ||= pop @{ Sisimai::RFC5322->received( $r->[-1] ) };
        }
        $e->{'diagnosis'} = Sisimai::String->sweep( $e->{'diagnosis'} );
        $e->{'status'}    = Sisimai::RFC3463->getdsn( $e->{'diagnosis'} );
        $e->{'spec'}      = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'}    = 'failed' if $e->{'status'} =~ m/\A[45]/;

    } # end of for()

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

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::MailMarshalSMTP->version;

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

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut


