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

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
