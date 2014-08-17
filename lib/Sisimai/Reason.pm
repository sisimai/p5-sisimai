package Sisimai::Reason;
use feature ':5.10';
use strict;
use warnings;
use Module::Load;

sub get {
    # @Description  Detect bounce reason
    # @Param <obj>  (Sisimai::Data) Parsed email object
    # @Return       (String) Bounce reason
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return $argvs->reason if length $argvs->reason;

    my $reasontext = '';
    my $classorder = [
        'UserUnknown', 'Filtered', 'Rejected', 'HostUnknown', 'MailboxFull',
        'MesgTooBig', 'ExceedLimit', 'Blocked',
    ];

    if( $argvs->diagnostictype eq 'SMTP' ) {
        # Diagnostic-Code: SMTP; ...
        for my $e ( @$classorder ) {
            # Check the value of Diagnostic-Code: and the value of Status:, it is a
            # deliverystats, with true() method in each Sisimai::Reason::* class.
            my $p = 'Sisimai::Reason::'.$e;
            Module::Load::load( $p );

            next unless $p->true( $argvs );
            $reasontext = $p->text;
            last;
        }
    }

    if( not $reasontext ) {
        # Bounce reason is not detected yet.
        while( 1 ) {
            # Check with other patterns
            my $p = '';

            # Onhold ?
            $p = 'Sisimai::Reason::OnHold';
            Module::Load::load( $p );
            $reasontext = $p->text if $p->true( $argvs );
            last if $reasontext;

            # Other reason ?
            $reasontext = __PACKAGE__->anotherone( $argvs );
            last if $reasontext;

            # Relaying Denied ?
            $p = 'Sisimai::Reason::RelayingDenied';
            Module::Load::load( $p );
            $reasontext = $p->text if $p->true( $argvs );
            last;
        }
        $reasontext ||= 'undefined';
    }

    return $reasontext;
}

sub anotherone {
    # @Description  Detect bounce reason
    # @Param <obj>  (Sisimai::Data) Parsed email object
    # @Return       (String) Bounce reason
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return $argvs->reason if $argvs->reason;

    my $statuscode = $argvs->deliverystatus // '';
    my $diagnostic = $argvs->diagnosticcode // '';
    my $reasontext = '';
    my $classorder = [
        'MailboxFull', 'SecurityError', 'SystemError', 'Suspend', 'Expired',
        'ContentError', 'NotAccept', 'MailerError',
    ];

    require Sisimai::RFC3463;
    for my $e ( 'temporary', 'permanent' ) {
        $reasontext = Sisimai::RFC3463->reason( $statuscode, $e );
        last if $reasontext;
    }

    if( $reasontext eq '' || $reasontext =~ m/\A(?:undefined|userunknown)\z/ ) {
        # Could not decide the reason by the value of Status:
        for my $e ( @$classorder ) {
            # Trying to match with other patterns in Sisimai::Reason::* classes
            my $p = 'Sisimai::Reason::'.$e;
            Module::Load::load( $p );

            next unless $p->match( $diagnostic );
            $reasontext = lc $e;
            last;
        }

        if( not $reasontext ) {
            # Check the value of Status:
            my $v = substr( $statuscode, 0, 3 );
            if( $v eq '5.6' || $v eq '4.6' ) {
                #  X.6.0   Other or undefined media error
                $reasontext = 'contenterror';

            } elsif( $v eq '5.7' || $v eq '4.7' ) {
                #  X.7.0   Other or undefined security status
                $reasontext = 'securityerror';

            } elsif( $argvs->diagnostictype eq 'X-UNIX' ) {
                # Diagnostic-Code: X-UNIX; ...
                $reasontext = 'mailererror';
            }
        }
    }
    return $reasontext;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason - Detect the bounce reason

=head1 SYNOPSIS

    use Sisimai::Reason;

=head1 DESCRIPTION

Sisimai::Reason detects the bounce reason from the content of Sisimai::Data
object as an argument of get() method. This class is called only Sisimai::Data
class.

=head1 CLASS METHODS

=head2 C<B<get( I<Sisimai::Data Object> )>>

C<get()> detects the bounce reason.

=head2 C<B<anotherone( I<Sisimai::Data object> )>>

C<anotherone()> is a method for detecting the bounce reason, it works as a fall
back method of get() and called only from get() method.

=head1 LIST OF BOUNCE REASONS

C<Sisimai::Reason->get()> detects the reason of bounce with parsing the bounced
messages. The following reasons will be set in the value of C<reason> property
of Sisimai::Data instance.

=head2 C<blocked>

Clienet hostname: the argument of C<HELO/EHLO>, is rejected.

=head2 C<contenterror>

The value of C<Status> header or the value of C<deliverystatus> is 5.6.X or the
original message is invalid format message and so on.

=head2 C<exceedlimit>

The value of C<Status> header or the value of C<deliverystatus> is X.2.3 or the
message size exceeded the limit of recipient's mailbox size limit.

=head2 C<expired>

Delivery time has expired.

=head2 C<filtered>

The recipient address rejected at the end of DATA command.

=head2 C<hostunknown>

The host part of the recipient address does not exist or the value of C<Status>
header or the value of C<deliverystatus> is 5.1.2.

=head2 C<mailboxfull>

The recipient's mailbox is full or the value of C<Status> header or the value of
C<deliverystatus> is X.2.2

=head2 C<mailererror>

Mailer program at the remote host exit with the status code except 0 and 75.

=head2 C<mesgtoobig>

SMTP session rejected due to the message size exceeded server limit or the value
of C<Status> header or the value of C<deliverystatus> is X.3.4.

=head2 C<notaccept>

Remote server does not accept email.

=head2 C<onhold>

Could not detect the reason of bounce.

=head2 C<rejected>

The sender email address rejected or the value of C<Status> header or the value
of C<deliverystatus> is X.1.8.

=head2 C<norelaying>

Relaying denied.

=head2 C<securityerror>

Message rejected due to SPAM content or virus or other security reason. The value
of C<Status> header or the value of C<deliverystatus> is X.7.Y.

=head2 C<suspend>

The recipient's mailbox temporary disabled.

=head2 C<systemerror>

Configuration error on the remote host or network error.

=head2 C<systemfull>

Disk full or other similar status on the remote server.

=head2 C<userunknown>

Recipient address does not exist or the value of C<Status> header or the value
of C<deliverystatus> is 5.1.1.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
