package Sisimai::CED::US::AmazonSES;
use parent 'Sisimai::CED';
use feature ':5.10';
use strict;
use warnings;

sub description { 'Amazon SES(JSON): http://aws.amazon.com/ses/' };
sub smtpagent   { 'US::AmazonSES' }

# x-amz-sns-message-id: 02f86d9b-eecf-573d-b47d-3d1850750c30
# x-amz-sns-subscription-arn: arn:aws:sns:us-west-2:000000000000:SESEJB:ffffffff-2222-2222-2222-eeeeeeeeeeee
sub headerlist  { return ['x-amz-sns-message-id'] };

sub scan {
    # Detect an error from Amazon SES(JSON)
    # @param         [Hash] mhead       Message header of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email(JSON)
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.0.2
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless defined $mhead->{'x-amz-sns-message-id'};
    return undef unless length  $mhead->{'x-amz-sns-message-id'};

    my @hasdivided = split("\n", $$mbody);
    my $jsonstring = '';
    my $foldedline = 0;

    while( my $e = shift @hasdivided ) {
        # Find JSON string from the message body
        next unless length $e;
        last if $e =~ m/\A[-]{2}\z/;
        last if $e eq '__END_OF_EMAIL_MESSAGE__';

        $e =~ s/\A[ ]// if $foldedline; # The line starts with " ", continued from !\n.
        $foldedline = 0;

        if( $e =~ m/[!]\z/ ) {
            # ... long long line ...![\n]
            $e =~ s/!\z//;
            $foldedline = 1;
        }
        $jsonstring .= $e;
    }
    return __PACKAGE__->adapt(\$jsonstring);
}

sub adapt {
    # @abstract      Adapt Amazon SES bounce object for Sisimai::Message format
    # @param         [String] argvs     bounce object(JSON) returned from each email cloud
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    my $class = shift;
    my $argvs = shift;
    my $stuff = undef;

    return undef unless ref $argvs eq 'SCALAR';
    return undef unless length $$argvs;

    eval {
        my $jsonparser = JSON->new;
        my $jsonobject = $jsonparser->decode($$argvs);

        if( exists $jsonobject->{'Message'} ) {
            # 'Message' => '{"notificationType":"Bounce",...
            $stuff = $jsonparser->decode($jsonobject->{'Message'});

        } else {
            # 'mail' => { 'sourceArn' => '...',... }, 'bounce' => {...},
            $stuff = $jsonobject;
        }
    };
    if( $@ ) {
        # Something wrong in decoding JSON
        warn sprintf(" ***warning: Failed to decode JSON: %s", $@);
        return undef;
    }

    return undef unless ref $stuff eq 'HASH';
    return undef unless keys %$stuff;

    use Sisimai::RFC5322;
    use Time::Piece;

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822part = '';    # (String) message/rfc822-headers part
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header

    my $b = $stuff->{'bounce'};
    my $v = undef;

    for my $e ( @{ $b->{'bouncedRecipients'} } ) {
        # {
        #   'emailAddress' => 'bounce@simulator.amazonses.com',
        #   'action' => 'failed',
        #   'status' => '5.1.1',
        #   'diagnosticCode' => 'smtp; 550 5.1.1 user unknown'
        # }
        next unless Sisimai::RFC5322->is_emailaddress($e->{'emailAddress'});

        $v = $dscontents->[-1];
        if( length $v->{'recipient'} ) {
            # There are multiple recipient addresses in the message body.
            push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
            $v = $dscontents->[-1];
        }
        $recipients++;
        $v->{'recipient'} = $e->{'emailAddress'};

        $v->{'action'} = $e->{'action'};
        $v->{'status'} = $e->{'status'};

        if( $e->{'diagnosticCode'} =~ m/\A(.+?);[ ]*(.+)\z/ ) {
            # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
            $v->{'spec'} = uc $1;
            $v->{'diagnosis'} = $2;

        } else {
            $v->{'diagnosis'} = $e->{'diagnosticCode'};
        }

        if( $b->{'reportingMTA'} =~ m/\Adsn;[ ](.+)\z/ ) {
            # 'reportingMTA' => 'dsn; a27-23.smtp-out.us-west-2.amazonses.com',
            $v->{'lhost'} = $1;
        }

        eval {
            $b->{'timestamp'} =~ s/[.]\d+Z\z//;
            $v->{'date'} = Time::Piece->strptime($b->{'timestamp'}, "%Y-%m-%dT%T");
        };
        $v->{'agent'} = __PACKAGE__->smtpagent;
    }

    for my $e ( @{ $stuff->{'mail'}->{'headers'} } ) {
        # 'headers' => [ { 'name' => 'From', 'value' => 'neko@nyaan.jp' }, ... ],
        next unless $e->{'name'} =~ m/\A(?:From|To|Subject)\z/;
        push @$rfc822list, sprintf("%s: %s", $e->{'name'}, $e->{'value'});
    }

    if( $stuff->{'mail'}->{'messageId'} ) {
        # 'messageId' => '01010157e48f9b9b-891e9a0e-9c9d-4773-9bfe-608f2ef4756d-000000'
        push @$rfc822list, sprintf("Message-Id: %s", $stuff->{'mail'}->{'messageId'});
    }

    $rfc822part = Sisimai::RFC5322->weedout($rfc822list);
    return { 'ds' => $dscontents, 'rfc822' => $$rfc822part };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::CED::US::AmazonSES - bounce mail parser class for C<Amazon SES(JSON)>.

=head1 SYNOPSIS

    use Sisimai::CED::US::AmazonSES;

=head1 DESCRIPTION

Sisimai::CED::US::AmazonSES parses a bounce object as JSON which created by
C<Amazon Simple Email Service>. Methods in the module are called from only 
Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::CED::US::AmazonSES->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::CED::US::AmazonSES->smtpagent;

=head2 C<B<scan(I<header data>, I<reference to body string>)>>

C<scan()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head2 C<B<adapt(I<JSON as String>)>>

C<adapt()> method adapts Amazon SES bounce object (JSON) for Perl hash object
used at Sisimai::Message class.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
