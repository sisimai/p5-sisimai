package Sisimai::Group::HR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Republic of Croatia/Republika Hrvatska
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.net/ http://t-mobile.hr/
            qr/\Asms[.]t-mobile[.]hr\z/,    # 385domestic-number@
            qr/\Ainstantemail[.]t-mobile[.]hr\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::HR::Phone - Major phone provider's domains in Croatia

=head1 SYNOPSIS

    use Sisimai::Group::HR::Phone;
    print Sisimai::Group::HR::Phone->find('sms.t-mobile.hr');  # t-mobile

=head1 DESCRIPTION

Sisimai::Group::HR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Croatia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
