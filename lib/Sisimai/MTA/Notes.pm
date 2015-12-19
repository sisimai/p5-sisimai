package Sisimai::MTA::Notes;
use parent 'Sisimai::MTA';
use feature ':5.10';
use strict;
use warnings;
use Encode;

my $Re0 = {
    'subject' => qr/\AUndeliverable message/,
};
my $Re1 = {
    'begin'   => qr/\A[-]+[ ]+Failure Reasons[ ]+[-]+\z/,
    'rfc822'  => qr/^[-]+[ ]+Returned Message[ ]+[-]+$/,
    'endof'   => qr/\A__END_OF_EMAIL_MESSAGE__\z/,
};

my $ReFailure = {
    'userunknown' => qr{(?:
         User[ ]not[ ]listed[ ]in[ ]public[ ]Name[ ][&][ ]Address[ ]Book
        |ディレクトリのリストにありません
        )
    }x,
    'networkerror' => qr/Message has exceeded maximum hop count/,
};

my $Indicators = __PACKAGE__->INDICATORS;
my $LongFields = Sisimai::RFC5322->LONGFIELDS;
my $RFC822Head = Sisimai::RFC5322->HEADERFIELDS;

sub description { 'Lotus Notes' }
sub smtpagent   { 'Notes' }
sub pattern     { return $Re0 }

sub scan {
    # Detect an error from Lotus Notes
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
    # @since v4.1.1
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ $Re0->{'subject'};

    require Sisimai::Address;

    my $dscontents = []; push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
    my @hasdivided = split( "\n", $$mbody );
    my $rfc822next = { 'from' => 0, 'to' => 0, 'subject' => 0 };
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $previousfn = '';    # (String) Previous field name
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $characters = '';    # (String) Character set name of the bounce mail
    my $removedmsg = 'MULTIBYTE CHARACTERS HAVE BEEN REMOVED';
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

        unless( length $characters ) {
            # Get character set name
            if( $mhead->{'content-type'} =~ m/\A.+;[ ]*charset=(.+)\z/ ) {
                # Content-Type: text/plain; charset=ISO-2022-JP
                $characters = lc $1;
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

            # ------- Failure Reasons  --------
            # 
            # User not listed in public Name & Address Book
            # kijitora@notes.example.jp
            #
            # ------- Returned Message --------
            $v = $dscontents->[ -1 ];
            if( $e =~ m/\A([^ ]+[@][^ ]+)/ ) {
                # kijitora@notes.example.jp
                if( length $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[ -1 ];
                }
                $v->{'recipient'} ||= $e;
                $recipients++;

            } else {
                next if $e =~ m/\A\z/;
                next if $e =~ m/\A[-]+/;

                if( $e =~ m/[^\x20-\x7e]/ ) {
                    # Error message is not ISO-8859-1
                    my $s = $e;
                    if( length $characters ) {
                        # Try to convert string
                        eval { Encode::from_to( $s, $characters, 'utf8' ); };
                        if( $@ ) {
                            # Failed to convert
                            $s = $removedmsg;
                        }

                    } else {
                        $s = $removedmsg;
                    }

                    # $s = $removedmsg if $s =~ m/[^\x20-\x7e]/;
                    $v->{'diagnosis'} .= $s;

                } else {
                    # Error message does not include multi-byte character
                    $v->{'diagnosis'} .= $e;
                }
            }
        } # End of if: rfc822
    }

    unless( $recipients ) {
        # Fallback: Get the recpient address from RFC822 part
        if( $rfc822part =~ m/^To:[ ]*(.+)$/m ) {
            $v->{'recipient'} = Sisimai::Address->s3s4( $1 );
            $recipients++ if $v->{'recipient'};
        }
    }
    return undef unless $recipients;

    require Sisimai::String;
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
        $e->{'recipient'} = Sisimai::Address->s3s4( $e->{'recipient'} );

        for my $r ( keys %$ReFailure ) {
            # Check each regular expression of Notes error messages
            next unless $e->{'diagnosis'} =~ $ReFailure->{ $r };
            $e->{'reason'} = $r;

            my $s = Sisimai::SMTP::Status->code( $r );
            $e->{'status'} = $s if length $s;
            last;
        }

        $e->{'spec'} = $e->{'reason'} eq 'mailererror' ? 'X-UNIX' : 'SMTP';
        $e->{'action'} = 'failed' if $e->{'status'} =~ m/\A[45]/;

    } # end of for()
    return { 'ds' => $dscontents, 'rfc822' => $rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::MTA::Notes - bounce mail parser class for C<Lotus Notes Server>.

=head1 SYNOPSIS

    use Sisimai::MTA::Notes;

=head1 DESCRIPTION

Sisimai::MTA::Notes parses a bounce email which created by C<Lotus Notes 
Server>. Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::MTA::Notes->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::MTA::Notes->smtpagent;

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

