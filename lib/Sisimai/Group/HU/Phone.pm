package Sisimai::Group::HU::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Hungary
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.hu/
            qr/\Ainstantemail[.]t-mobile[.]hu\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::HU::Phone - Major phone provider's domains in Hungary

=head1 SYNOPSIS

    use Sisimai::Group::HU::Phone;
    print Sisimai::Group::HU::Phone->find('instantemail.blackberry.com');  # t-mobile

=head1 DESCRIPTION

Sisimai::Group::HU::Phone has a domain list of major cellular phone providers
and major smart phone providers in Hungary.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
