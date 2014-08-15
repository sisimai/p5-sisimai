package Sisimai::Group::TW::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Taiwan
        'taiwanmobile' => [
            # TaiwanMobile; http://www.taiwanmobile.com/
            qr/\Ataiwanmobile[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::TW::Phone - Major phone provider's domains in Taiwan

=head1 SYNOPSIS

    use Sisimai::Group::TW::Phone;
    print Sisimai::Group::TW::Phone->find('taiwanmobile.blackberry.com');  # taiwanmobile

=head1 DESCRIPTION

Sisimai::Group::TW::Phone has a domain list of major cellular phone providers
and major smart phone providers in Taiwan.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
