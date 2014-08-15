package Sisimai::Group::VN::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Socialist Republic of Vietnam
        'viettel' => [
            # Viettel Telecom; http://vietteltelecom.vn/
            qr/\Aviettel[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::VN::Phone - Major phone provider's domains in Vietnam

=head1 SYNOPSIS

    use Sisimai::Group::VN::Phone;
    print Sisimai::Group::VN::Phone->find('viettel.blackberry.com');   # viettel

=head1 DESCRIPTION

Sisimai::Group::VN::Phone has a domain list of major cellular phone providers
and major smart phone providers in Vietnam.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
