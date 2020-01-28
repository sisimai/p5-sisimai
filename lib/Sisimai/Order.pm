package Sisimai::Order;
use feature ':5.10';
use strict;
use warnings;
use Sisimai::Lhost;

my $OrderE1 = [
    # These modules have many subject patterns or have MIME encoded subjects
    # which is hard to code as regular expression
    'Sisimai::Lhost::Exim',
    'Sisimai::Lhost::Exchange2003',
];
my $OrderE2 = [
    # These modules have no MTA specific header and did not listed in the
    # following subject header based regular expressions.
    'Sisimai::Lhost::Exchange2007',
    'Sisimai::Lhost::Facebook',
    'Sisimai::Lhost::KDDI',
];
my $OrderE3 = [
    # These modules have no MTA specific header but listed in the following
    # subject header based regular expressions.
    'Sisimai::Lhost::Postfix',
    'Sisimai::Lhost::Sendmail',
    'Sisimai::Lhost::qmail',
    'Sisimai::Lhost::SendGrid',
    'Sisimai::Lhost::Courier',
    'Sisimai::Lhost::OpenSMTPD',
    'Sisimai::Lhost::Notes',
    'Sisimai::Lhost::MessagingServer',
    'Sisimai::Lhost::Domino',
    'Sisimai::Lhost::Bigfoot',
    'Sisimai::Lhost::EinsUndEins',
    'Sisimai::Lhost::MXLogic',
    'Sisimai::Lhost::Amavis',
    'Sisimai::Lhost::IMailServer',
    'Sisimai::Lhost::X4',
];
my $OrderE4 = [
    # These modules have no MTA specific headers and there are few samples or
    # too old MTA
    'Sisimai::Lhost::Verizon',
    'Sisimai::Lhost::InterScanMSS',
    'Sisimai::Lhost::MailFoundry',
    'Sisimai::Lhost::ApacheJames',
    'Sisimai::Lhost::Biglobe',
    'Sisimai::Lhost::EZweb',
    'Sisimai::Lhost::X5',
    'Sisimai::Lhost::X3',
    'Sisimai::Lhost::X2',
    'Sisimai::Lhost::X1',
    'Sisimai::Lhost::V5sendmail',
];
my $OrderE5 = [
    # These modules have one or more MTA specific headers but other headers
    # also required for detecting MTA name
    'Sisimai::Lhost::Outlook',
    'Sisimai::Lhost::MailRu',
    'Sisimai::Lhost::MessageLabs',
    'Sisimai::Lhost::MailMarshalSMTP',
    'Sisimai::Lhost::mFILTER',
    'Sisimai::Lhost::Google',
];
my $OrderE9 = [
    # These modules have one or more MTA specific headers
    'Sisimai::Lhost::GSuite',
    'Sisimai::Lhost::Aol',
    'Sisimai::Lhost::Office365',
    'Sisimai::Lhost::Yahoo',
    'Sisimai::Lhost::GMX',
    'Sisimai::Lhost::Yandex',
    'Sisimai::Lhost::AmazonSES',
    'Sisimai::Lhost::ReceivingSES',
    'Sisimai::Lhost::AmazonWorkMail',
    'Sisimai::Lhost::Zoho',
    'Sisimai::Lhost::McAfee',
    'Sisimai::Lhost::Activehunter',
    'Sisimai::Lhost::SurfControl',
    'Sisimai::Lhost::FML',
];

# The following order is decided by the first word of Subject: header
my $Subject = {
    'complaint-about'  => ['Sisimai::ARF'],
    'delivery-failure' => ['Sisimai::Lhost::Domino', 'Sisimai::Lhost::X2'],
    'delivery-notification' => ['Sisimai::Lhost::MessagingServer'],
    'delivery-status'  => [
        'Sisimai::Lhost::GSuite',
        'Sisimai::Lhost::Google',
        'Sisimai::Lhost::Outlook',
        'Sisimai::Lhost::McAfee',
        'Sisimai::Lhost::OpenSMTPD',
        'Sisimai::Lhost::AmazonSES',
        'Sisimai::Lhost::ReceivingSES',
        'Sisimai::Lhost::X3',
    ],
    'email-feedback'   => ['Sisimai::ARF'],
    'failure-delivery' => ['Sisimai::Lhost::X2'],
    'failure-notice'   => [
        'Sisimai::Lhost::Yahoo',
        'Sisimai::Lhost::qmail',
        'Sisimai::Lhost::mFILTER',
        'Sisimai::Lhost::Activehunter',
        'Sisimai::Lhost::X4',
    ],
    'loop-alert' => ['Sisimai::Lhost::FML'],
    'notice'     => ['Sisimai::Lhost::Courier'],
    'mail-delivery' => [
        'Sisimai::Lhost::Exim',
        'Sisimai::Lhost::MailRu',
        'Sisimai::Lhost::GMX',
        'Sisimai::Lhost::EinsUndEins',
        'Sisimai::Lhost::Zoho',
        'Sisimai::Lhost::MessageLabs',
        'Sisimai::Lhost::MXLogic',
    ],
    'mail-not'    => ['Sisimai::Lhost::X4'],
    'mail-system' => ['Sisimai::Lhost::EZweb'],
    'message-delivery'   => ['Sisimai::Lhost::MailFoundry'],
    'message-frozen'     => ['Sisimai::Lhost::Exim'],
    'permanent-delivery' => ['Sisimai::Lhost::X4'],
    'postmaster-notify'  => ['Sisimai::Lhost::Sendmail'],
    'returned-mail' => [
        'Sisimai::Lhost::Sendmail',
        'Sisimai::Lhost::Aol',
        'Sisimai::Lhost::V5sendmail',
        'Sisimai::Lhost::Bigfoot',
        'Sisimai::Lhost::Biglobe',
        'Sisimai::Lhost::X1',
    ],
    'sorry-your' => ['Sisimai::Lhost::Facebook'],
    'undeliverable-mail' => [
        'Sisimai::Lhost::Amavis',
        'Sisimai::Lhost::MailMarshalSMTP',
        'Sisimai::Lhost::IMailServer',
    ],
    'undeliverable' => [
        'Sisimai::Lhost::Office365',
        'Sisimai::Lhost::Exchange2007',
        'Sisimai::Lhost::Aol',
        'Sisimai::Lhost::Exchange2003',
    ],
    'undeliverable-message' => ['Sisimai::Lhost::Notes', 'Sisimai::Lhost::Verizon'],
    'undelivered-mail' => [
        'Sisimai::Lhost::Postfix',
        'Sisimai::Lhost::Aol',
        'Sisimai::Lhost::SendGrid',
        'Sisimai::Lhost::Zoho',
    ],
    'warning' => ['Sisimai::Lhost::Sendmail', 'Sisimai::Lhost::Exim'],
};

sub make {
    # Returns an MTA Order decided by the first word of the "Subject": header
    # @param         [String] argv0 Subject header string
    # @return        [Array]        Order of MTA modules
    # @since         v4.25.4
    my $class = shift;
    my $argv0 = shift || return [];
    my @words = split(/[ ]/, lc($argv0), 3);
    my $first = '';

    if( rindex($words[0], ':') > 0 ) {
        # Undeliverable: ..., notify: ...
        $first = shift @words;

    } else {
        # Postmaster notify, returned mail, ...
        $first = join('-', splice(@words, 0, 2));
    }
    $first =~ y/:[]",*//d;
    return $Subject->{ $first } || [];
}

sub default {
    # Make default order of MTA modules to be loaded
    # @return   [Array] Default order list of MTA modules
    # @since v4.13.1
    return [map { 'Sisimai::Lhost::'.$_ } @{ Sisimai::Lhost->index() }];
}

sub another {
    # Make MTA modules list as a spare
    # @return   [Array] Ordered module list
    # @since v4.13.1
    return [@$OrderE1, @$OrderE2, @$OrderE3, @$OrderE4, @$OrderE5, @$OrderE9];
};

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Order - A Class for making an optimized order list for calling MTA
modules in Sisimai::Lhost::*.

=head1 SYNOPSIS

    use Sisimai::Order

=head1 DESCRIPTION

Sisimai::Order class makes optimized order list which include MTA modules to be
loaded on first from MTA specific headers in the bounce mail headers such as
X-Failed-Recipients, which MTA modules for JSON structure.

=head1 CLASS METHODS

=head2 C<B<default()>>

C<default()> returns a default order of MTA modules as an array reference. The
default order is defined at Sisimai::Lhost->index method.

    print for @{ Sisimai::Order->default };

=head2 C<B<another()>>

C<another()> returns another list of MTA modules as an array reference. Another
list is defined at this class.

    print for @{ Sisimai::Order->another };

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2015-2017,2019,2020 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
