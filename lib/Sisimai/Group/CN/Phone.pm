package Sisimai::Group::CN::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in China
        'chinamobile' => [
            # http://www.10086.cn/
            # China Mobile; http://www.chinamobileltd.com/
            qr/\A139[.]com\z/,
            qr/\Achinamobile[.]blackberry[.]com\z/,
        ],
        'chinaunicom' => [
            # China unicom; http://www.10010.com/
            qr/\Achinaunicom[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CN::Phone - Major phone provider's domains in China

=head1 SYNOPSIS

    use Sisimai::Group::CN::Phone;
    print Sisimai::Group::CN::Phone->find('139.com');    # chinamobile

=head1 DESCRIPTION

Sisimai::Group::CN::Phone has a domain list of major cellular phone providers
and major smart phone providers in China.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
