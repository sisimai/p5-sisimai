package Sisimai::Group::SA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Kingdom of Saudi Arabia
        'mobily' => [
            # Mobily; http://www.mobily.com.sa/
            qr/\Amobily[.]blackberry[.]com\z/,
        ],
        'stc' => [
            # Saudi Telecom; http://www.stc.com.sa/
            qr/\Astc[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SA::Phone - Major phone provider's domains in Kingdom of Saudi Arabia

=head1 SYNOPSIS

    use Sisimai::Group::SA::Phone;
    print Sisimai::Group::SA::Phone->find('stc.blackberry.com');   # stc

=head1 DESCRIPTION

Sisimai::Group::SA::Phone has a domain list of major cellular phone providers
and major smart phone providers in Kingdom of Saudi Arabia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
