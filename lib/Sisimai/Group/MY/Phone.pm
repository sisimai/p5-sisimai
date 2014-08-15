package Sisimai::Group::MY::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Malaysia
        'digi' => [
            # DiGi; http://www.digi.com.my/
            qr/\Adigi[.]?my[.]blackberry[.]com\z/,
        ],
        'maxis' => [
            # Maxis; http://www.maxis.com.my/
            qr/\Amaxis[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MY::Phone - Major phone provider's domains in Malaysia

=head1 SYNOPSIS

    use Sisimai::Group::MY::Phone;
    print Sisimai::Group::MY::Phone->find('maxis.blackberry.com'); # maxis

=head1 DESCRIPTION

Sisimai::Group::MY::Phone has a domain list of major cellular phone providers
and major smart phone providers in Malaysia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
