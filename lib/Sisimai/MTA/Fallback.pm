package Sisimai::MTA::Fallback;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Address;

sub version     { '4.0.0' };
sub description { 'Fallback Module for MTAs' };
sub smtpagent   { 'Fallback' };

sub scan {
    # @Description  Detect an error for fallback
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Array) Bounce data list
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    require Sisimai::MDA;
    require Sisimai::RFC3463;

    my $scannedset = Sisimai::MDA->scan( $mhead, $mbody );
    my $rfc822head = {};
    my $dscontents = __PACKAGE__->DELIVERYSTATUS;
    my $softbounce = 0;
    my $recipients = 0;

    my $v = $dscontents;

    if( $scannedset && $scannedset->{'reason'} ) {
        # Make bounce data by the values returned from Sisimai::MDA->scan()
        $v->{'agent'}     = $scannedset->{'mda'} || __PACKAGE__->smtpagent;
        $v->{'reason'}    = $scannedset->{'reason'};
        $v->{'command'}   = '';
        $v->{'diagnosis'} = $scannedset->{'message'};

        $softbounce = 1 if Sisimai::RFC3463->is_softbounce( $v->{'diagnosis'} );
        my $s = $softbounce ? 't' : 'p';
        my $r = Sisimai::RFC3463->status( $scannedset->{'reason'}, $s, 'i' );
        $v->{'status'} = $r || Sisimai::RFC3463->status( 'undefined', $s, 'i' );

    } else {

        if( $$mbody =~ m/^Diagnostic-Code:[ ]*(.+)/im ) {
            # Get the value of "Diagnostic-Code" header from the body part.
            $v->{'diagnosis'} = $1;
            $v->{'command'}   = 'DATA';
        }

        if( $$mbody =~ m/^Status:[ ]*(\d[.]\d+[.]\d+)$/im ) {
            # Sisimai::MDA->scan did not return valid data
            # Status: 5.1.1
            $v->{'status'} = $1;

        } else {
            # There is no "Status:" header in the message body
            $v->{'status'} = Sisimai::RFC3463->getdsn( $v->{'diagnosis'} );
            $softbounce = 1 if Sisimai::RFC3463->is_softbounce( $v->{'diagnosis'} );
            my $s = $softbounce ? 't' : 'p';

            unless( $v->{'status'} ) {
                # Failed to get the value of Status
                $v->{'status'} = Sisimai::RFC3463->status( 'undefined', $s, 'i' );
            }
        }
    }

    # Seek the message body to get required headers
    if( $$mbody =~ m/^Final-Recipient:[ ]*rfc822;[ ]*([^ ]+)$/im ||
        $$mbody =~ m/^Original-Recipient:\s*rfc822;\s*([^ ]+)$/mi ) {
        # Final-Recipient: RFC822; userunknown@example.jp
        $v->{'recipient'} = Sisimai::Address->s3s4( $1 );
    } 

    if( $$mbody =~ m/^X-Actual-Recipient:[ ]*rfc822;[ ]*([^ ]+)$/im ) {
        # X-Actual-Recipient: RFC822; kijitora@example.co.jp
        $v->{'alias'} = $1;
    } 
    
    if( $$mbody =~ m/^Action:[ ]*(.+)$/im ) {
        # Action: failed
        $v->{'action'} = lc $1;
    }

    if( $$mbody =~ m/^Remote-MTA:[ ]*dns;[ ]*(.+)$/im ) {
        # Remote-MTA: DNS; mx.example.jp
        $v->{'rhost'} = lc $1;
    }

    if( $$mbody =~ m/^Reporting-MTA:[ ]*dns;[ ]*(.+)$/im ) {
        # Reporting-MTA: dns; mx.example.jp
        $v->{'lhost'} = lc $1;
    }

    if( $$mbody =~ m/^(?:Last-Attempt|Arrival)-Date:[ ]*(.+)$/im ) {
        # Last-Attempt-Date: Fri, 14 Feb 2014 12:30:08 -0500
        $v->{'date'} = $1;
    }

    $v->{'agent'} ||= __PACKAGE__->smtpagent;

    return { 'ds' => [ $v ], 'rfc822' => '' };
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::MTA::Fallback - bounce mail parser class for Fallback.

=head1 SYNOPSIS

    use Sisimai::MTA::Fallback;

=head1 DESCRIPTION

Sisimai::MTA::Fallback is a class which called from called from only Sisimai::Message
when other Sisimai::MTA::* modules did not detected a bounce reason.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::Fallback->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Fallback->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MDA name or string 'Fallback'.

    print Sisimai::MTA::Fallback->smtpagent;

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
