package Sisimai::Lhost::GoogleGroups;
use parent 'Sisimai::Lhost';
use v5.26;
use strict;
use warnings;

sub description { 'Google Groups: https://groups.google.com' }
sub inquire {
    # Detect an error from Google Groups
    # @param    [Hash] mhead    Message headers of a bounce email
    # @param    [String] mbody  Message body of a bounce email
    # @return   [Hash]          Bounce data list and message/rfc822 part
    # @return   [undef]         failed to decode or the arguments are missing
    # @since v4.25.6
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless rindex($mhead->{'from'}, '<mailer-daemon@googlemail.com>')  > -1;
    return undef unless  index($mhead->{'subject'}, 'Delivery Status Notification') > -1;
    return undef unless exists $mhead->{'x-failed-recipients'};
    return undef unless exists $mhead->{'x-google-smtp-source'};

    # Hello kijitora@libsisimai.org,
    #
    # We're writing to let you know that the group you tried to contact (group-name)
    # may not exist, or you may not have permission to post messages to the group.
    # A few more details on why you weren't able to post:
    #
    #  * You might have spelled or formatted the group name incorrectly.
    #  * The owner of the group may have removed this group.
    #  * You may need to join the group before receiving permission to post.
    #  * This group may not be open to posting.
    #
    # If you have questions related to this or any other Google Group,
    # visit the Help Center at https://groups.google.com/support/.
    #
    # Thanks,
    #
    # Google Groups
    state $boundaries = ['----- Original message -----', 'Content-Type: message/rfc822'];
    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailparts = Sisimai::RFC5322->part($mbody, $boundaries);
    my $recipients = 0;
    my $v          = $dscontents->[-1];
    my @entiremesg = split(/\n\n/, $emailparts->[0], 5); pop @entiremesg;
    my $issuedcode = join(' ', @entiremesg); $issuedcode =~ y/\n/ /;
    my $receivedby = $mhead->{'received'} || [];
    my $recordwide = {
        'rhost'     => Sisimai::RFC5322->received($receivedby->[0])->[1],
        'reason'    => 'onhold',
        'diagnosis' => Sisimai::String->sweep($issuedcode),
    };

    # * You might have spelled or formatted the group name incorrectly.
    # * The owner of the group may have removed this group.
    # * You may need to join the group before receiving permission to post.
    # * This group may not be open to posting.
    my $fewdetails = [$emailparts->[0] =~ /^[ ]?[*][ ]?/gm] || [];
    $recordwide->{'reason'} = 'rejected' if scalar @$fewdetails == 4;

    for my $e ( split(',', $mhead->{'x-failed-recipients'}) ) {
        # X-Failed-Recipients: neko@example.jp, nyaan@example.org, ...
        next unless Sisimai::Address->is_emailaddress($e);

        if( $v->{'recipient'} ) {
            # There are multiple recipient addresses in the message body.
            push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
            $v = $dscontents->[-1];
        }
        $v->{'recipient'} = Sisimai::Address->s3s4($e);
        $recipients++;
        $v->{ $_ } = $recordwide->{ $_ } for keys %$recordwide;
    }
    return undef unless $recipients;
    return { 'ds' => $dscontents, 'rfc822' => $emailparts->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::GoogleGroups - bounce mail decoder class for Google Groups L<https://groups.google.com>.

=head1 SYNOPSIS

    use Sisimai::Lhost::GoogleGroups;

=head1 DESCRIPTION

C<Sisimai::Lhost::GoogleGroups> decodes a bounce email which created by Google Groups L<https://groups.google.com>.
Methods in the module are called from only C<Sisimai::Message>.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::GoogleGroups->description;

=head2 C<B<inquire(I<header data>, I<reference to body string>)>>

C<inquire()> method decodes a bounced email and return results as a array reference.
See C<Sisimai::Message> for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2020-2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

