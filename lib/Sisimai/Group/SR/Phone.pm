package Sisimai::Group::SR::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Suriname/Republiek Suriname
        'telesur' => [
            # Telesur; http://www.telesur.sr/
            qr/\Ateleg[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::SR::Phone - Major phone provider's domains in Suriname

=head1 SYNOPSIS

    use Sisimai::Group::SR::Phone;
    print Sisimai::Group::SR::Phone->find('teleg.blackberry.com'); # telesur

=head1 DESCRIPTION

Sisimai::Group::SR::Phone has a domain list of major cellular phone providers
and major smart phone providers in Suriname.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
