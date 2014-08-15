package Sisimai::Group::SK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Slovakia/Slovak Republic
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.sk/
            qr/\Atmobilesk[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SK::Phone - Major phone provider's domains in Slovakia

=head1 SYNOPSIS

    use Sisimai::Group::SK::Phone;
    print Sisimai::Group::SK::Phone->find('tmobilesk.blackberry.com'); # t-mobile

=head1 DESCRIPTION

Sisimai::Group::SK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Slovakia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
