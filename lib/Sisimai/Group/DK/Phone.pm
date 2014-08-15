package Sisimai::Group::DK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Kingdom of Denmark/Kongeriget Danmark
        'telenor' => [
            # Telenor; http://www.telenor.dk/
            qr/\Atelenor[.]?dk[.]blackberry[.]com\z/,
        ],
        'telia' => [
            # Telia; http://telia.dk/
            qr/\Ateliadk[.]blackberry[.]com\z/,
        ],
        'three' => [
            # 3; http://www.3.dk/
            qr/\Atre[.]blackberry[.]com\z/, # ...?
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::DK::Phone - Major phone provider's domains in Kingdom of Denmark

=head1 SYNOPSIS

    use Sisimai::Group::DK::Phone;
    print Sisimai::Group::DK::Phone->find('tre.blackberry.com');   # three

=head1 DESCRIPTION

Sisimai::Group::DK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kingdom of Denmark.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
