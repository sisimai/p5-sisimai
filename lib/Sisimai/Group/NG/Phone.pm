package Sisimai::Group::NG::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Federal Republic of Nigeria
        'glomobile' => [
            # Glo Mobile; http://www.gloworld.com/
            qr/\Agloworld[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NG::Phone - Major phone provider's domains in Nigeria

=head1 SYNOPSIS

    use Sisimai::Group::NG::Phone;
    print Sisimai::Group::NG::Phone->find('gloworld.blackberry.com');  # glomobile

=head1 DESCRIPTION

Sisimai::Group::NG::Phone has a domain list of major cellular phone providers
and major smart phone providers in Nigeria.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
