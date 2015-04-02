package Sisimai::Reason::UserUnknown;
use feature ':5.10';
use strict;
use warnings;

sub text  { 'userunknown' }
sub match {
    my $class = shift;
    my $argvs = shift // return undef;
    my $regex = qr{(?>
         .+[ ]user[ ]unknown
        |[#]5[.]1[.]1[ ]bad[ ]address
        |[<].+[>][ ]not[ ]found
        |address[ ]does[ ]not[ ]exist
        |archived[ ]recipient
        |destination[ ]server[ ]rejected[ ]recipients
        |email[ ]address[ ]does[ ]not[ ]exist
        |invalid[ ](?:
             mailbox[ ]path
            |recipient                 # Linkedin
            )
        |is[ ]not[ ](?:
             a[ ]known[ ]user
            |an[ ]active[ ]address[ ]at[ ]this[ ]host
            )
        |mailbox[ ](?:
             not[ ]present
            |not[ ]found
            |unavailable
            )
        |no[ ]account[ ]by[ ]that[ ]name[ ]here
        |no[ ]such[ ](?:
             mailbox
            |person[ ]at[ ]this[ ]address
            |recipient
            |user(?:[ ]here)?
            )
        |no[ ].+[ ]in[ ]name[ ]directory
        |recipient[ ](?:
             .+[ ]was[ ]not[ ]found[ ]in
            |address[ ]rejected:[ ](?:
                 access[ ]denied
                |invalid[ ]user
                |user[ ].+[ ]does[ ]not[ ]exist
                |user[ ]unknown[ ]in[ ].+[ ]table
                |unknown[ ]user
                )
            |does[ ]not[ ]exist[ ]on[ ]this[ ]system
            |is[ ]not[ ]local
            |not[ ]found
            )
        |requested[ ]action[ ]not[ ]taken:[ ]mailbox[ ]unavailable
        |said:[ ]550[-[ ]]5[.]1[.]1[ ].+[ ]user[ ]unknown[ ]
        |sorry,[ ](?:
             user[ ]unknown
            |badrcptto
            |no[ ]mailbox[ ]here[ ]by[ ]that[ ]name
            )
        |this[ ]address[ ]no[ ]longer[ ]accepts[ ]mail
        |this[ ]user[ ]doesn[']?t[ ]have[ ]a[ ].+[ ]account
        |undeliverable[ ]address
        |unknown[ ](?:
             address
            |local[- ]part
            |recipient
            |user
            )
        |user[ ](?:
             .+[ ]was[ ]not[ ]found
            |missing[ ]home[ ]directory
            |not[ ]found     # 550 User not found. See http://mail.bigmir.net/err/2/
            |unknown
            )
        |vdeliver:[ ]invalid[ ]or[ ]unknown[ ]virtual[ ]user
        )
    }xi;

    return 1 if $argvs =~ $regex;
    return 0;
}

sub true {
    # @Description  Whether the address is "userunknown" or not
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (Integer) 1 = is unknown user
    #               (Integer) 0 = is not unknown user.
    # @See          http://www.ietf.org/rfc/rfc2822.txt
    my $class = shift;
    my $argvs = shift // return undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    return 1 if $argvs->reason eq __PACKAGE__->text;

    require Sisimai::RFC3463;
    my $prematches = [ 'RelayingDenied', 'NotAccept', 'MailboxFull' ];
    my $matchother = 0;
    my $statuscode = $argvs->deliverystatus // '';
    my $reasontext = __PACKAGE__->text;
    my $tempreason = '';
    my $diagnostic = '';
    my $v = 0;

    $tempreason = Sisimai::RFC3463->reason( $statuscode ) if $statuscode;
    $diagnostic = $argvs->diagnosticcode // '';
    return 0 if $tempreason eq 'suspend';

    if( $tempreason eq $reasontext ) {
        # *.1.1 = 'Bad destination mailbox address'
        #   Status: 5.1.1
        #   Diagnostic-Code: SMTP; 550 5.1.1 <***@example.jp>:
        #     Recipient address rejected: User unknown in local recipient table
        require Module::Load;
        for my $e ( @$prematches ) {
            # Check the value of "Diagnostic-Code" with other error patterns.
            my $p = 'Sisimai::Reason::'.$e;
            Module::Load::load( $p );

            if( $p->match( $diagnostic ) ) {
                # Match with reason defined in Sisimai::Reason::* Except 
                # UserUnknown.
                $matchother = 1;
                last;
            }
        }

        # Did not match with other message patterns
        $v = 1 if $matchother == 0;

    } else {
        # Check the last SMTP command of the session. 
        if( $argvs->smtpcommand eq 'RCPT' ) {
            # When the SMTP command is not "RCPT", the session rejected by other
            # reason, maybe.
            $v = 1 if __PACKAGE__->match( $diagnostic );
        }
    }

    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::UserUnknown - Bounce reason is C<userunknown> or not.

=head1 SYNOPSIS

    use Sisimai::Reason::UserUnknown;
    print Sisimai::Reason::UserUnknown->match('550 5.1.1 Unknown User');   # 1

=head1 DESCRIPTION

Sisimai::Reason::UserUnknown checks the bounce reason is C<userunknown> or not.
This class is called only Sisimai::Reason class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> returns string: C<userunknown>.

    print Sisimai::Reason::UserUnknown->text;  # userunknown

=head2 C<B<match( I<string> )>>

C<match()> returns 1 if the argument matched with patterns defined in this class.

    print Sisimai::Reason::UserUnknown->match('550 5.1.1 Unknown User');   # 1

=head2 C<B<true( I<Sisimai::Data> )>>

C<true()> returns 1 if the bounce reason is C<userunknown>. The argument must be
Sisimai::Data object and this method is called only from Sisimai::Reason class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2015 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
