package Sisimai::MTA::mFILTER;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;

my $RxMTA = {
    'from'     => qr/\AMailer Daemon [<]MAILER-DAEMON[@]/,
    'begin'    => qr/\A[^ ]+[@][^ ]+[.][a-zA-Z]+\z/,
    'error'    => qr/\A-------server message\z/,
    'command'  => qr/\A-------SMTP command\z/,
    'endof'    => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
    'rfc822'   => qr/\A-------original (?:message|mail info)\z/,
    'subject'  => qr/\Afailure notice\z/,
    'x-mailer' => qr/\Am-FILTER\z/,
};

sub version     { '4.0.5' }
sub description { 'Digital Arts m-FILTER' }
sub smtpagent   { 'm-FILTER' }
sub headerlist  { return [ 'X-Mailer' ] }

sub scan {
    # @Description  Detect an error from DigitalArts m-FILTER
    # @Param <ref>  (Ref->Hash) Message header
    # @Param <ref>  (Ref->String) Message body
    # @Return       (Ref->Hash) Bounce data list and message/rfc822 part
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless defined $mhead->{'x-mailer'};
    return undef unless $mhead->{'x-mailer'} =~ $RxMTA->{'x-mailer'};
    return undef unless $mhead->{'subject'}  =~ $RxMTA->{'subject'};

    my $dscontents = [];    # (Ref->Array) SMTP session errors: message/delivery-status
    my $rfc822head = undef; # (Ref->Array) Required header list in message/rfc822 part
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $previousfn = '';    # (String) Previous field name

    my $longfields = __PACKAGE__->LONGFIELDS;
    my @stripedtxt = split( "\n", $$mbody );
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $markingset = { 'diagnosis' => 0, 'command' => 0 };

    my $v = undef;
    my $p = '';
    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    $rfc822head = __PACKAGE__->RFC822HEADERS;

    for my $e ( @stripedtxt ) {
        # Read each line between $RxMTA->{'begin'} and $RxMTA->{'rfc822'}.
        if( ( $e =~ $RxMTA->{'rfc822'} ) .. ( $e =~ $RxMTA->{'endof'} ) ) {
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
            next unless ( $e =~ $RxMTA->{'begin'} ) .. ( $e =~ $RxMTA->{'rfc822'} );
            next unless length $e;
            # このメールは「m-FILTER」が自動的に生成して送信しています。
            # メールサーバーとの通信中、下記の理由により
            # このメールは送信できませんでした。
            #
            # 以下のメールアドレスへの送信に失敗しました。
            # kijitora@example.jp
            #
            #
            # -------server message
            # 550 5.1.1 unknown user <kijitora@example.jp>
            #
            # -------SMTP command
            # DATA
            #
            # -------original message
            $v = $dscontents->[ -1 ];

            if( $e =~ m/\A([^ ]+[@][^ ]+)\z/ ) {
                # 以下のメールアドレスへの送信に失敗しました。
                # kijitora@example.jp
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} = $1;
                $recipients++;

            } elsif( $e =~ m/\A[A-Z]{4}/ ) {
                # -------SMTP command
                # DATA
                next if $v->{'command'};
                $v->{'command'} = $e if $markingset->{'command'};

            } else {
                # Get error message and SMTP command
                if( $e =~ $RxMTA->{'error'} ) {
                    # -------server message
                    $markingset->{'diagnosis'} = 1;

                } elsif( $e =~ $RxMTA->{'command'} ) {
                    # -------SMTP command
                    $markingset->{'command'} = 1;

                } else {
                    # 550 5.1.1 unknown user <kijitora@example.jp>
                    next if $e =~ m/\A[-]+/;
                    next if $v->{'diagnosis'};
                    $v->{'diagnosis'} = $e;
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
        $e->{'agent'} = __PACKAGE__->smtpagent;

        if( scalar @{ $mhead->{'received'} } ) {
            # Get localhost and remote host name from Received header.
            my $r = $mhead->{'received'};
            my $x = Sisimai::RFC5322->received( $r->[-1] );

            $e->{'lhost'} ||= shift @{ Sisimai::RFC5322->received( $r->[0] ) };
            for my $ee ( @$x ) {
                # Avoid "... by m-FILTER"
                next unless $ee =~ m/[.]/;
                $e->{'rhost'} = $ee;
            }
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

Sisimai::MTA::mFILTER - bounce mail parser class for C<Digital Arts m-FILTER>.

=head1 SYNOPSIS

    use Sisimai::MTA::mFILTER;

=head1 DESCRIPTION

Sisimai::MTA::mFILTER parses a bounce email which created by C<Digital Arts 
m-FILTER>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<version()>>

C<version()> returns the version number of this module.

    print Sisimai::MTA::mFILTER->version;

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::mFILTER->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::mFILTER->smtpagent;

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

