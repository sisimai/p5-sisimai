package Sisimai::Group::MK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Macedonia
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.mk/
            qr/\Ainstantemail[.]t-mobile[.]mk\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MK::Phone - Major phone provider's domains in Macedonia

=head1 SYNOPSIS

    use Sisimai::Group::MK::Phone;
    print Sisimai::Group::MK::Phone->find('instantemail.t-mobile.mk'); # t-mobile

=head1 DESCRIPTION

Sisimai::Group::MK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Macedonia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
