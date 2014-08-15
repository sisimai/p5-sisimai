package Sisimai::Group::UA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Ukraine
        'mtc' => [
            # MTC; http://www.mts.com.ua/
            qr/\Amtsua[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::UA::Phone - Major phone provider's domains in Ukraine

=head1 SYNOPSIS

    use Sisimai::Group::UA::Phone;
    print Sisimai::Group::UA::Phone->find('mtsua.blackberry.com'); # mtc

=head1 DESCRIPTION

Sisimai::Group::UA::Phone has a domain list of major cellular phone providers
and major smart phone providers in Ukraine.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
