package Sisimai::MTA::UserDefined;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'from'    => qr/\AMail Delivery Subsystem/,
    'begin'   => qr/\A\s+[-]+ Transcript of session follows [-]+\z/,
    'error'   => qr/\A[.]+ while talking to .+[:]\z/,
    'rfc822'  => qr{\AContent-Type:[ ]*(?:message/rfc822|text/rfc822-headers)\z},
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'subject' => qr/(?:see transcript for details\z|\AWarning: )/,
};

sub description { 'Module decription' }
sub smtpagent   { 'Module name' }
sub headerlist  { return [ 'X-Some-UserDefined-Header' ] }

sub scan {
    # @Description  UserDefined MTA module
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    my $match = 0;

    # 1. Check some value in $mhead using regular expression or "eq" operator
    #    whether the bounce message should be parsed by this module or not.
    #   - Matched 1 or more values: Proceed to the step 2.
    #   - Did not matched:          return undef;
    #
    MATCH: {
        $match = 1 if $mhead->{'subject'} =~ $RxMTA->{'subject'};
        $match = 1 if $mhead->{'from'}    =~ $RxMTA->{'from'};
        $match = 1 if $mhead->{'x-some-userdefined-header'};
    }
    return undef unless $match;

    # 2. Parse message body($mbody) of the bounce message. See some modules in
    #    lib/Sisimai/MTA or lib/Sisimai/MSP directory to implement codes.
    #
    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $recipients = 0;     # (Integer) The number of recipient addresses in the bounce message

    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    # The following code is dummy to be passed "make test".
    $recipients = 1;
    $dscontents->[0]->{'recipient'} = 'kijitora@example.jp';
    $dscontents->[0]->{'diagnosis'} = '550 something wrong';
    $dscontents->[0]->{'status'}    = '5.1.1';
    $dscontents->[0]->{'spec'}      = 'SMTP';
    $dscontents->[0]->{'date'}      = 'Thu 29 Apr 2010 23:34:45 +0900';
    $dscontents->[0]->{'agent'}     = __PACKAGE__->smtpagent();

    $rfc822part .= 'From: shironeko@example.org'."\n";
    $rfc822part .= 'Subject: Nyaaan'."\n";
    $rfc822part .= 'Message-Id: 000000000000@example.jp'."\n";

    # 3. Return undef when there is no recipient address which is failed to
    #    delivery in the bounce message
    return undef unless $recipients;

    # 4. Return the following variable.
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::UserDefined - User defined MTA module as an example

=head1 SYNOPSIS

    use lib '/path/to/your/lib/dir';
    use Your::Custom::MTA::Module;
    use Sisimai::Mail;
    use Sisimai::Data;
    use Sisimai::Message;

    my $file = '/path/to/mailbox';
    my $mail = Sisimai::Mail->new( $file );
    my $mesg = undef;
    my $data = undef;

    while( my $r = $mail->read ){ 
        $mesg = Sisimai::Message->new( 
                    'data' => $r,
                    'load' => [ 'Your::Custom::MTA::Module' ]
                ); 
        $data = Sisimai::Data->make( 'data' => $mesg ); 
        ...
    }

=head1 DESCRIPTION

Sisimai::MTA::UserDefined is an example module as a template to implement your
custom MTA module.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Your::Custom::MTA::Module->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Your::Custom::MTA::Module->smtpagent;

=head2 C<B<scan( I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
