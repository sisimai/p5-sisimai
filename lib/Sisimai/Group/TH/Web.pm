package Sisimai::Group::TH::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's web mail domains in Kingdom of Thailand
        'thaimail' => [
            # ThaiMail; http://www.thaimail.com/
            qr/\Athaimail[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::TH::Web - Major web mail service provider's domains in Thailand

=head1 SYNOPSIS

    use Sisimai::Group::TH::Web;
    print Sisimai::Group::TH::Web->find('thaimail.com');    # thaimail

=head1 DESCRIPTION

Sisimai::Group::TH::Web has a domain list of major web mail service providers
in Thailand.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
