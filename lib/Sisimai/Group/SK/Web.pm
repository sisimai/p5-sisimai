package Sisimai::Group::SK::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in lovakia/Slovak Republic
        'centrum' => [
            # Centrum.sk; http://pobox.centrum.sk/
            qr/\Apobox[.]sk\z/,
        ],
        'sme' => [
            # SME.sk; http://post.sme.sk/
            qr/\Apost[.]sk\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SK::Web - Major web mail service provider's domains in Slovakia

=head1 SYNOPSIS

    use Sisimai::Group::SK::Web;
    print Sisimai::Group::SK::Web->find('post.sk');    # sme

=head1 DESCRIPTION

Sisimai::Group::SK::Web has a domain list of major web mail service providers
in Slovakia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
