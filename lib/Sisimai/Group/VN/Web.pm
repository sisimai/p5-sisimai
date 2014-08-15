package Sisimai::Group::VN::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Socialist Republic of Vietnam
        'megaplus' => [
            # MegaPlus; http://vnn.vn/
            qr/\Avdc[.]com[.]vn\z/,
            qr/\Avnn[.]vn\z/,
            qr/\A(?:hn|dng|hcn|fmail|pmail)[.]vnn[.]vn\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::VN::Web - Major web mail service provider's domains in Vietnam

=head1 SYNOPSIS

    use Sisimai::Group::VN::Web;
    print Sisimai::Group::VN::Web->find('vnn.vn');    # megaplus

=head1 DESCRIPTION

Sisimai::Group::VN::Web has a domain list of major web mail service providers
in Vietnam.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
