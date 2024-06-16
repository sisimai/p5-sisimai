package Sisimai::Reason;
use v5.26;
use strict;
use warnings;

my $ModulePath = __PACKAGE__->path;
my $GetRetried = __PACKAGE__->retry;
my $ClassOrder = [
    [qw/MailboxFull MesgTooBig ExceedLimit Suspend HasMoved NoRelaying AuthFailure UserUnknown
        Filtered RequirePTR NotCompliantRFC Rejected HostUnknown SpamDetected Speeding TooManyConn
        Blocked/
    ],
    [qw/MailboxFull SpamDetected PolicyViolation VirusDetected NoRelaying AuthFailure BadReputation
        SecurityError SystemError NetworkError Speeding Suspend Expired ContentError SystemFull
        NotAccept MailerError/
    ],
    [qw/MailboxFull MesgTooBig ExceedLimit Suspend UserUnknown Filtered Rejected HostUnknown
        SpamDetected Speeding TooManyConn Blocked SpamDetected AuthFailure SecurityError SystemError
        NetworkError Suspend Expired ContentError HasMoved SystemFull NotAccept MailerError
        NoRelaying SyntaxError OnHold/
    ],
];

sub retry {
    # Reason list better to retry detecting an error reason
    # @return   [Hash] Reason list
    return {
        'undefined' => 1, 'onhold' => 1, 'systemerror' => 1, 'securityerror' => 1, 'expired' => 1,
        'suspend' => 1, 'networkerror' => 1, 'hostunknown' => 1, 'userunknown'=> 1
    };
}

sub index {
    # All the error reason list Sisimai support
    # @return   [Array] Reason list
    return [qw/
        AuthFailure BadReputation Blocked ContentError ExceedLimit Expired Filtered HasMoved
        HostUnknown MailboxFull MailerError MesgTooBig NetworkError NotAccept NotCompliantRFC
        OnHold Rejected NoRelaying SpamDetected VirusDetected PolicyViolation SecurityError
        Speeding Suspend RequirePTR SystemError SystemFull TooManyConn UserUnknown SyntaxError/
    ];
}

sub path {
    # Returns Sisimai::Reason::* module path table
    # @return   [Hash] Module path table
    # @since    v4.25.6
    my $class = shift;
    my $index = __PACKAGE__->index;
    my $table = {};
    $table->{ __PACKAGE__.'::'.$_ } = 'Sisimai/Reason/'.$_.'.pm' for @$index;
    return $table;
}

sub get {
    # Detect the bounce reason
    # @param    [Hash]   argvs  Decoded email object
    # @return   [String]        Bounce reason or undef if the argument is missing or not HASH
    # @see anotherone
    my $class = shift;
    my $argvs = shift // return undef;

    unless( exists $GetRetried->{ $argvs->{'reason'} } ) {
        # Return a reason text already decided except a reason matched with the regular expression
        # of ->retry() method.
        return $argvs->{'reason'} if $argvs->{'reason'};
    }
    return 'delivered' if substr($argvs->{'deliverystatus'}, 0, 2) eq '2.';

    my $reasontext = '';
    my $issuedcode = $argvs->{'diagnosticcode'} || '';
    my $codeformat = $argvs->{'diagnostictype'} || '';
    if( $codeformat eq 'SMTP' || $codeformat eq '' ) {
        # Diagnostic-Code: SMTP; ... or empty value
        for my $e ( $ClassOrder->[0]->@* ) {
            # Check the values of Diagnostic-Code: and Status: fields using true() method of each
            # child class in Sisimai::Reason
            my $p = 'Sisimai::Reason::'.$e;
            require $ModulePath->{ $p };

            next unless $p->true($argvs);
            $reasontext = $p->text;
            last;
        }
    }

    if( not $reasontext || $reasontext eq 'undefined' ) {
        # Bounce reason is not detected yet.
        $reasontext   = __PACKAGE__->anotherone($argvs);
        $reasontext   = '' if $reasontext eq 'undefined';
        $reasontext ||= 'expired' if $argvs->{'action'} eq 'delayed';
        return $reasontext if $reasontext;

        # Try to match with message patterns in Sisimai::Reason::Vacation
        require Sisimai::Reason::Vacation;
        $reasontext   = 'vacation' if Sisimai::Reason::Vacation->match(lc $issuedcode);
        $reasontext ||= 'onhold'   if $issuedcode;
        $reasontext ||= 'undefined';
    }
    return $reasontext;
}

sub anotherone {
    # Detect the other bounce reason, fall back method for get()
    # @param    [Hash] argvs    Decoded email structure
    # @return   [String]        Bounce reason or undef if the argument is missing or not HASH
    # @see get
    my $class = shift;
    my $argvs = shift // return undef;
    return $argvs->{'reason'} if $argvs->{'reason'};

    require Sisimai::SMTP::Status;
    my $issuedcode = lc $argvs->{'diagnosticcode'} // '';
    my $codeformat = $argvs->{'diagnostictype'}    // '';
    my $actiontext = $argvs->{'action'}            // '';
    my $statuscode = $argvs->{'deliverystatus'}    // '';
    my $reasontext = Sisimai::SMTP::Status->name($statuscode) || '';

    TRY_TO_MATCH: while(1) {
        my $trytomatch   = $reasontext eq '' ? 1 : 0;
           $trytomatch ||= 1 if exists $GetRetried->{ $reasontext };
           $trytomatch ||= 1 if $codeformat ne 'SMTP';
        last unless $trytomatch;

        # Could not decide the reason by the value of Status:
        for my $e ( $ClassOrder->[1]->@* ) {
            # Trying to match with other patterns in Sisimai::Reason::* classes
            my $p = 'Sisimai::Reason::'.$e;
            require $ModulePath->{ $p };

            next unless $p->match($issuedcode);
            $reasontext = lc $e;
            last;
        }
        last(TRY_TO_MATCH) if $reasontext;

        # Check the value of Status:
        my $code2digit = substr($statuscode, 0, 3) || '';
        if( $code2digit eq '5.6' || $code2digit eq '4.6' ) {
            #  X.6.0   Other or undefined media error
            $reasontext = 'contenterror';

        } elsif( $code2digit eq '5.7' || $code2digit eq '4.7' ) {
            #  X.7.0   Other or undefined security status
            $reasontext = 'securityerror';

        } elsif( CORE::index($codeformat, 'X-UNIX') == 0 ) {
            # Diagnostic-Code: X-UNIX; ..., X-Postfix, or other X-*
            $reasontext = 'mailererror';

        } else {
            # 50X Syntax Error?
            require Sisimai::Reason::SyntaxError;
            $reasontext = 'syntaxerror' if Sisimai::Reason::SyntaxError->true($argvs);
        }
        last(TRY_TO_MATCH) if $reasontext;

        # Check the value of Action: field, first
        if( CORE::index($actiontext, 'delayed') == 0 || CORE::index($actiontext, 'expired') == 0 ) {
            # Action: delayed, expired
            $reasontext = 'expired';

        } else {
            # Check the value of SMTP command
            my $thecommand = $argvs->{'smtpcommand'} // '';
            if( $thecommand eq 'EHLO' || $thecommand eq 'HELO' ) {
                # Rejected at connection or after EHLO|HELO
                $reasontext = 'blocked';
            }
        }
        last(TRY_TO_MATCH);
    }
    return $reasontext;
}

sub match {
    # Detect the bounce reason from given text
    # @param    [String] argv1  Error message
    # @return   [String]        Bounce reason
    my $class = shift;
    my $argv1 = shift // return undef;

    my $reasontext = '';
    my $issuedcode = lc $argv1;

    # Diagnostic-Code: SMTP; ... or empty value
    for my $e ( $ClassOrder->[2]->@* ) {
        # Check the values of Diagnostic-Code: and Status: fields using true() method of each child
        # class in Sisimai::Reason
        my $p = 'Sisimai::Reason::'.$e;
        require $ModulePath->{ $p };

        next unless $p->match($issuedcode);
        $reasontext = $p->text;
        last;
    }
    return $reasontext if $reasontext;

    if( CORE::index(uc $issuedcode, 'X-UNIX; ') > -1 ) {
        # X-Unix; ...
        $reasontext = 'mailererror';

    } else {
        # Detect the bounce reason from "Status:" code
        require Sisimai::SMTP::Status;
        my $cv = Sisimai::SMTP::Status->find($argv1)   || '';
        $reasontext = Sisimai::SMTP::Status->name($cv) || 'undefined';
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

C<Sisimai::Reason> detects the bounce reason from the content of C<Sisimai::Fact> object as an argument
of C<get()> method. This class is called only C<Sisimai::Fact> class.

=head1 CLASS METHODS

=head2 C<B<get(I<Sisimai::Fact Object>)>>

C<get()> method detects the bounce reason.

=head2 C<B<anotherone(I<Sisimai::Fact object>)>>

C<anotherone()> method is a method for detecting the bounce reason, it works as a fall back method
of C<get()> and called only from C<get()> method.

C<match()> detects the bounce reason from given text as a error message.

=head2 C<B<match(I<String>)>>

C<match()> method is a method for detecting the bounce reason from the string given as an argument
of the method. However, this method is low analytical precision.

=head1 LIST OF BOUNCE REASONS

C<Sisimai::Reason->get()> method detects the reason of bounce with decoding the bounced messages.
The following reasons will be set in the value of C<reason> property of C<Sisimai::Fact> instance.
The list of all the bounce reasons is available at L<https://libsisimai.org/en/reason/>.

=head1 SEE ALSO

L<Sisimai::ARF>
L<http://tools.ietf.org/html/rfc5965>
L<https://libsisimai.org/en/reason/>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

