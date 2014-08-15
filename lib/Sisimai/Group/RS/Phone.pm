package Sisimai::Group::RS::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Serbia
        'telenor' => [
            # Telenor: Privatni korisnici; http://www.telenor.rs/
            qr/\Atelenorserbia[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::RS::Phone - Major phone provider's domains in Serbia

=head1 SYNOPSIS

    use Sisimai::Group::RS::Phone;
    print Sisimai::Group::RS::Phone->find('telenorsebia.blackberry.com'); # telenor 

=head1 DESCRIPTION

Sisimai::Group::RS::Phone has a domain list of major cellular phone providers
and major smart phone providers in Serbia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
