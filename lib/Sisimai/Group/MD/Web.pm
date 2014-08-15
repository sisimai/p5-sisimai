package Sisimai::Group::MD::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Republica Moldova
        'mail.md' => [
            # mail.md; https://www.mail.md/
            qr/\Amail[.]md\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MD::Web - Major web mail service provider's domains in Moldova

=head1 SYNOPSIS

    use Sisimai::Group::MD::Web;
    print Sisimai::Group::MD::Web->find('mail.md');    # mail.md

=head1 DESCRIPTION

Sisimai::Group::MD::Web has a domain list of major web mail service providers
in Moldova.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
