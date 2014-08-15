package Sisimai::Group::CA::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Canada
        'hush' => [
            # Hushmail http://www.hushmail.com/
            qr/\Ahushmail[.](?:com|me)\z/,
            qr/\Ahush[.](?:com|ai)\z/,
            qr/\Amac[.]hush[.]com\z/,
        ],
        'zworg' => [
            # Zworg.com; https://zworg.com/
            qr/\Azworg[.]com\z/,
            qr/\A(?:irk|mailcanada)[.]ca\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CA::Web - Major web mail service provider's domains in Canada

=head1 SYNOPSIS

    use Sisimai::Group::CA::Web;
    print Sisimai::Group::CA::Web->find('hush.com');    # hush

=head1 DESCRIPTION

Sisimai::Group::CA::Web has a domain list of major web mail service providers
in Canada.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
