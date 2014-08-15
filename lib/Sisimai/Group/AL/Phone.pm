package Sisimai::Group::AL::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Albania
        'amc' => [
            # AMC; http://www.amc.al/
            qr/\Aamc[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AL::Phone - Major phone provider's domains in Albania

=head1 SYNOPSIS

    use Sisimai::Group::AL::Phone;
    print Sisimai::Group::AL::Phone->find('amc.blackberry.com');   # amc

=head1 DESCRIPTION

Sisimai::Group::AL::Phone has a domain list of major cellular phone providers
and major smart phone providers in Albania.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
