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

# This variable don't hold MTA module name which have one or more MTA specific
# header such as X-AWS-Outgoing, X-Yandex-Uniq.
my $Pattern = {
    'subject' => {
        'delivery' => [
            'Sisimai::Lhost::Exim',
            'Sisimai::Lhost::Outlook',
            'Sisimai::Lhost::Courier',
            'Sisimai::Lhost::Domino',
            'Sisimai::Lhost::OpenSMTPD',
            'Sisimai::Lhost::EinsUndEins',
            'Sisimai::Lhost::InterScanMSS',
            'Sisimai::Lhost::MailFoundry',
            'Sisimai::Lhost::X4',
            'Sisimai::Lhost::X3',
            'Sisimai::Lhost::X2',
            'Sisimai::Lhost::Google',
        ],
        'noti' => [
            'Sisimai::Lhost::Sendmail',
            'Sisimai::Lhost::qmail',
            'Sisimai::Lhost::Outlook',
            'Sisimai::Lhost::Courier',
            'Sisimai::Lhost::MessagingServer',
            'Sisimai::Lhost::OpenSMTPD',
            'Sisimai::Lhost::X4',
            'Sisimai::Lhost::X3',
            'Sisimai::Lhost::mFILTER',
            'Sisimai::Lhost::Google',
        ],
        'return' => [
            'Sisimai::Lhost::Postfix',
            'Sisimai::Lhost::Sendmail',
            'Sisimai::Lhost::SendGrid',
            'Sisimai::Lhost::Bigfoot',
            'Sisimai::Lhost::EinsUndEins',
            'Sisimai::Lhost::X1',
            'Sisimai::Lhost::Biglobe',
            'Sisimai::Lhost::V5sendmail',
        ],
        'undeliver' => [
            'Sisimai::Lhost::Postfix',
            'Sisimai::Lhost::Office365',
            'Sisimai::Lhost::Exchange2007',
            'Sisimai::Lhost::Exchange2003',
            'Sisimai::Lhost::SendGrid',
            'Sisimai::Lhost::Notes',
            'Sisimai::Lhost::Verizon',
            'Sisimai::Lhost::Amavis',
            'Sisimai::Lhost::IMailServer',
            'Sisimai::Lhost::MailMarshalSMTP',
        ],
        'failure' => [
            'Sisimai::Lhost::qmail',
            'Sisimai::Lhost::Outlook',
            'Sisimai::Lhost::MailRu',
            'Sisimai::Lhost::Domino',
            'Sisimai::Lhost::X4',
            'Sisimai::Lhost::X2',
            'Sisimai::Lhost::mFILTER',
            'Sisimai::Lhost::Google',
        ],
        'warning' => [
            'Sisimai::Lhost::Postfix',
            'Sisimai::Lhost::Sendmail',
            'Sisimai::Lhost::Exim',
        ],
    },
};
my $Subject = __PACKAGE__->by('subject');

sub make {
    # Check headers for detecting MTA module and returns the order of modules
    # @param         [Hash] heads   Email header data
    # @return        [Array]        Order of MTA modules
    # @since         v4.25.4
    my $class = shift;
    my $heads = shift || return [];

    return [] unless exists $heads->{'subject'};
    return [] unless $heads->{'subject'};

    # Try to match the value of "Subject" with patterns generated by
    # Sisimai::Order->by('subject') method
    my $order = [];
    my $title = lc $heads->{'subject'};
    for my $e ( keys %$Subject ) {
        # Get MTA list from the subject header
        next if index($title, $e) == -1;
        push @$order, @{ $Subject->{ $e } }; # Matched and push MTA list
        last;
    }
    return $order;
}

sub by {
    # Get regular expression patterns for specified field
    # @param    [String] group  Group name for "ORDER BY"
    # @return   [Hash]          Pattern table for the group
    # @since v4.13.2
    my $class = shift;
    my $group = shift || return undef;

    return $Pattern->{ $group } if exists $Pattern->{ $group };
    return {};
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

=head2 C<B<by(I<STRING>)>>

C<by()> receives a pattern name string as the 1st argument and returns a table
of MTA module. As of present, only C<subject> is supported at the 1st argument.

    my $tab = Sisimai::Order->by('subject');

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
