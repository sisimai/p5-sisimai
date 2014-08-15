package Sisimai::Group::SG::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Singapore
        'singtel' => [
            qr/\Ainsing[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SG::Web - Major web mail service provider's domains in Singapore

=head1 SYNOPSIS

    use Sisimai::Group::SG::Web;
    print Sisimai::Group::SG::Web->find('insing.com');    # singtel

=head1 DESCRIPTION

Sisimai::Group::SG::Web has a domain list of major web mail service providers
in Singapore.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
