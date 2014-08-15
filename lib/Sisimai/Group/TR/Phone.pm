package Sisimai::Group::TR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Turkey
        'avea' => [
            # Avea; http://www.avea.com.tr/
            qr/\Aavea[.]blackberry[.]com\z/,
        ],
        'turkcell' => [
            # Turkcell; http://www.turkcell.com.tr/
            qr/\Aturkcell[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::TR::Phone - Major phone provider's domains in Turkey

=head1 SYNOPSIS

    use Sisimai::Group::TR::Phone;
    print Sisimai::Group::TR::Phone->find('turkcell.blackberry.com');  # trukcell

=head1 DESCRIPTION

Sisimai::Group::TR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Turkey.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
