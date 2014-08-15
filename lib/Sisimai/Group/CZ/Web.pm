package Sisimai::Group::CZ::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Czech Republic/Czechia
        'seznam.cz' => [
            # Seznam, http://www.seznam.cz/
            qr/\A(?:seznam|email|post|spoluzaci|stream|firmy)[.]cz\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CZ::Web - Major web mail service provider's domains in Czech Republic

=head1 SYNOPSIS

    use Sisimai::Group::CZ::Web;
    print Sisimai::Group::CZ::Web->find('email.cz');    # seznam.cz

=head1 DESCRIPTION

Sisimai::Group::CZ::Web has a domain list of major web mail service providers
in Czech Republic.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
