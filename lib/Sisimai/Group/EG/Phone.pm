package Sisimai::Group::EG::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Arab Republic of Egypt
        'mobinil' => [
            # Mobinil; http://www.mobinil.com/
            qr/\Amobinil[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::EG::Phone - Major phone provider's domains in Egypt

=head1 SYNOPSIS

    use Sisimai::Group::EG::Phone;
    print Sisimai::Group::EG::Phone->find('mobinil.blackberry.com');   # mobinil

=head1 DESCRIPTION

Sisimai::Group::EG::Phone has a domain list of major cellular phone providers
and major smart phone providers in Egypt.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
