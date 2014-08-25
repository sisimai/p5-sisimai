package Sisimai::MDA;
use feature ':5.10';
use strict;
use warnings;

my $RxMDA = {
    # dovecot/src/deliver/deliver.c
    # 11: #define DEFAULT_MAIL_REJECTION_HUMAN_REASON \
    # 12: "Your message to <%t> was automatically rejected:%n%r"
    'dovecot'    => qr/\AYour message to .+ was automatically rejected:\z/,
    'mail.local' => qr/\Amail[.]local: /,
    'procmail'   => qr/\Aprocmail: /,
    'maildrop'   => qr/\Amaildrop: /,
    'vpopmail'   => qr/\Avdelivermail: /,
    'vmailmgr'   => qr/\Avdeliver: /,
};

my $RxFrom = [
    qr/\AMail Delivery Subsystem/,  # dovecot/src/deliver/mail-send.c:94
    qr/\AMAILER-DAEMON/i,
    qr/\Apostmaster/i,
];

my $RxErr = {
    'dovecot' => {
        'userunknown' => [
            qr/\AMailbox doesn't exist: /,
        ],
        'mailboxfull' => [
            qr/\AQuota exceeded [(]mailbox for user is full[)]\z/,  # dovecot/src/plugins/quota/quota.c
            qr/\ANot enough disk space\z/,
        ],
    },
    'mail.local' => {
        'userunknown' => [
            qr/: User unknown/,
            qr/: Invalid mailbox path/,
            qr/: User missing home directory/,
        ],
        'mailboxfull' => [
            qr/Disc quota exceeded\z/,
            qr/Mailbox full or quota exceeded/,
        ],
        'systemerror' => [
            qr/Temporary file write error/,
        ],
    },
    'procmail' => {
        'mailboxfull' => [
            qr/Quota exceeded while writing/,
        ],
        'systemfull' => [
            qr/No space left to finish writing/,
        ],
    },
    'maildrop' => {
        'userunknown' => [
            qr/Invalid user specified[.]\z/,
            qr/Cannot find system user/,
        ],
        'mailboxfull' => [
            qr/maildir over quota[.]\z/,
        ],
    },
    'vpopmail' => {
        'userunknown' => [
            qr/Sorry, no mailbox here by that name[.]/,
        ],
        'filtered' => [
            qr/account is locked email bounced/,
            qr/user does not exist, but will deliver to /,
        ],
        'mailboxfull' => [
            qr/(?:domain|user) is over quota/,
        ],
    },
    'vmailmgr' => {
        'userunknown' => [
            qr/Invalid or unknown base user or domain/,
            qr/Invalid or unknown virtual user/,
            qr/User name does not refer to a virtual user/,
        ],
        'mailboxfull' => [
            qr/Delivery failed due to system quota violation/,
        ],
    },
};

sub scan { 
    # @Description  Parse message body and return reason and text
    # @Param <ref>  (Ref->Hash) Message Header
    # @Param <ref>  (Ref->Scalar) Message body
    # @Return       (Ref->Hash) Error reason and error text
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless ref( $mhead ) eq 'HASH';
    return undef unless grep { $mhead->{'from'} =~ $_ } @$RxFrom;
    return undef unless ref( $mbody ) eq 'SCALAR';
    return undef unless length $$mbody;

    my $agentname0 = '';    # (String) MDA name
    my $reasonname = '';    # (String) Error reason
    my $bouncemesg = '';    # (String) Error message
    my $stripedtxt = [ split( "\n", $$mbody ) ];
    my $linebuffer = [];

    for my $e ( keys %$RxMDA ) {
        # Detect MDA from error string in the message body.
        $linebuffer = [];
        for my $f ( @$stripedtxt ) {
            # Check each line with each MDA's symbox regular expression.
            next if( $agentname0 eq '' && $f !~ $RxMDA->{ $e } );
            $agentname0 ||= $e;
            push @$linebuffer, $f;
            last if $f =~ m/\A\z/;
        }

        last if $agentname0;
    }

    return undef unless $agentname0;
    return undef unless scalar @$linebuffer;

    for my $e ( keys %{ $RxErr->{ $agentname0 } } ) {
        # Detect an error reason from message patterns of the MDA.
        for my $f ( @$linebuffer ) {

            next unless grep { $f =~ $_ } @{ $RxErr->{ $agentname0 }->{ $e } };
            $reasonname = $e;
            $bouncemesg = $f;
            last;
        }
        last if $bouncemesg && $reasonname;
    }

    return { 
        'mda'     => $agentname0, 
        'reason'  => $reasonname // '', 
        'message' => $bouncemesg // '',
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MDA - Error message parser for MDA

=head1 SYNOPSIS

    use Sisimai::MDA;
    my $header = { 'from' => 'mailer-daemon@example.jp' };
    my $string = 'mail.local: Disc quota exceeded';
    my $return = Sisimai::MDA->scan( $header, \$string );

=head1 DESCRIPTION

Sisimai::MDA parse bounced email which created by some MDA, such as C<dovecot>,
C<mail.local>, C<procmail>, and so on. 
This class is called from Sisimai::Message only.

=head1 CLASS METHODS

=head2 C<B<scan( I<Header>, I<Reference to message body> )>>

C<scan()> is a parser for detecting an error from mail delivery agent.

    my $header = { 'from' => 'mailer-daemon@example.jp' };
    my $string = 'mail.local: Disc quota exceeded';
    my $return = Sisimai::MDA->scan( $header, \$string );
    warn Dumper $return;
    $VAR1 = {
        'mda' => 'mail.local',
        'reason' => 'mailboxfull',
        'message' => 'mail.local: Disc quota exceeded'
    }

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
